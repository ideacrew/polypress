# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Documents
  # Operation to create document with inserts
  class CreateWithInsert
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])
    send(:include, ::EventSource::Command)
    send(:include, ::EventSource::Logging)
    include FamilyHelper

    # @param [Hash] AcaEntities::MagiMedicaid::Application
    # @param[Templates::TemplateModel] :template_model
    # @return [Dry::Monads::Result] Parsed template as string
    def call(params)
      # _template = yield fetch_template(params)
      documents_hash =
        yield create_main_document(
          params: params,
          template_model: params[:template_model]
        )

      # _inserts = yield append_inserts(params, template)
      _tax_document_path = generate_tax_documents(params) if tax_notice?(params)
      _other_pdfs = yield append_other_pdfs(params)
      _clear_tax_documents = yield clear_tax_documents if tax_notice?(params)
      Success(documents_hash)
    end

    private

    # def fetch_template(params)
    #   template = Templates::TemplateModel.where(key: params[:event_key]).first

    #   if template
    #     Success(template)
    #   else
    #     Failure("Unable to find template with #{params[:event_key]}")
    #   end
    # end

    # Creates main body of the document
    def create_main_document(
      params:,
      template_model:,
      cover_page: true,
      insert: false
    )
      result =
        document(
          params
            .slice(:entity, :preview, :recipient_hbx_id, :document_name)
            .merge({ template_model: template_model, cover_page: cover_page })
        )

      if result.is_a?(Hash)
        if insert
          insert_path = result[:document].path
          Success(join_pdfs([@main_document_path, insert_path]))
        else
          @main_document_path = result[:document].path
          Success(result)
        end
      else
        Failure(result)
      end
    end

    # Generic method to create a pdf document
    def document(params)
      document = Documents::Create.new.call(params)
      if document.success?
        document.success
      else
        unless Rails.env.test?
          logger.error(
            "Couldn't create document for the given payload: #{document.failure}"
          )
        end
        document.failure
      end
    end

    def attach_blank_page(template_path = nil)
      path = template_path.nil? ? @main_document_path : template_path
      blank_page = Rails.root.join("lib/pdf_templates/#{Settings.site.key}", 'blank.pdf')
      page_count = Prawn::Document.new(template: path).page_count
      join_pdfs([path, blank_page], path) if page_count.odd?
    end

    def join_pdfs(pdfs, path = nil)
      pdf = File.exist?(pdfs[0]) ? CombinePDF.load(pdfs[0]) : CombinePDF.new
      pdf << CombinePDF.load(pdfs[1])
      path_to_save = path.nil? ? @main_document_path : path
      pdf.save path_to_save
    end

    def ivl_appeal_rights
      join_pdfs [
        @main_document_path,
        Rails.root.join('lib/pdf_templates', 'appeals_maine.pdf')
      ]
    end

    def ivl_non_discrimination
      join_pdfs [
        @main_document_path,
        Rails.root.join(
          'lib/pdf_templates',
          'ivl_non_discrimination.pdf'
        )
      ]
    end

    def ivl_attach_envelope
      join_pdfs [
        @main_document_path,
        Rails.root.join("lib/pdf_templates/#{Settings.site.key}", "taglines.pdf")
      ]
    end

    def ivl_attach_1095a_form
      Failure("no tax document found to attach") unless @tax_document_path

      join_pdfs [
        @main_document_path,
        @tax_document_path
      ]
    end

    def generate_tax_documents(params)
      family_payload =
        if params[:preview].present?
          result = ::AcaEntities::Contracts::Families::FamilyContract.new.call(family_hash.deep_symbolize_keys)
          ::AcaEntities::Families::Family.new(result.to_h).to_h
        else
          params[:entity].to_h
        end

      # returns document path
      output = Documents::Append1095aDocuments.new.call({ payload: family_payload.to_h })
      if output.success?
        @tax_document_path = output.success
      else
        Failure("unable to generate tax documents")
      end
    end

    def verifications_insert_needed?(params, insert)
      (params[:entity]&.documents_needed || params[:preview].present?) &&
        insert_present?(insert)
    end

    def insert_present?(insert)
      Template.where(key: insert).present?
    end

    def append_inserts(params, template)
      output =
        template
        .inserts
        .sort
        .collect do |insert|
          unless verifications_insert_needed?(params, insert) ||
                 insert_present?(insert)
            Success(true)
            next
          end
          attach_blank_page
          create_main_document(
            params: params,
            key: insert,
            cover_page: false,
            insert: true
          )
        end
      failures = output.select(&:failure?)
      return Failure(failures) if failures.present?

      Success(true)
    end

    # append 1095A for initial, void and corrected only
    def tax_notice?(params)
      ['IVLTAX', 'IVLVTA', 'IVLTXC'].include?(params[:template_model].print_code.to_s)
    end

    def clear_tax_documents
      return unless @tax_document_path.present?

      Success(File.delete(@tax_document_path))
    end

    def append_other_pdfs(params)
      attach_blank_page

      # ivl_appeal_rights
      # ivl_non_discrimination
      ivl_attach_1095a_form if tax_notice?(params)
      ivl_attach_envelope
      Success(true)
    end
  end
end
