# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module MagiMedicaid
  # Operation to create template
  class PublishDocument
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])
    send(:include, ::EventSource::Command)
    send(:include, ::EventSource::Logging)

    # @param [Hash] AcaEntities::MagiMedicaid::Application
    # @param [String] :event_key
    # @return [Dry::Monads::Result] Parsed template as string
    def call(params)
      documents_hash = yield create_main_document(params)
      _verifications_insert = yield append_verifications_insert(params)
      _other_inserts = yield append_other_inserts
      uploaded_document = yield upload_document(documents_hash, params[:application_entity])
      event = yield build_event(uploaded_document)
      result = yield publish_response(event)
      Success(result)
    end

    private

    # Creates main body of the document
    def create_main_document(params)
      result = document({ key: params[:event_key], entity: params[:application_entity], cover_page: true })
      if result.is_a?(Hash)
        @main_document_path = result[:document].path
        Success(result)
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
        logger.error("Couldn't create document for the given payload: #{document.failure}") unless Rails.env.test?
        document.failure
      end
    end

    def attach_blank_page(template_path = nil)
      path = template_path.nil? ? @main_document_path : template_path
      blank_page = Rails.root.join('lib/pdf_templates', 'blank.pdf')
      page_count = Prawn::Document.new(:template => path).page_count
      join_pdfs([path, blank_page], path) if page_count.odd?
    end

    def join_pdfs(pdfs, path = nil)
      pdf = File.exist?(pdfs[0]) ? CombinePDF.load(pdfs[0]) : CombinePDF.new
      pdf << CombinePDF.load(pdfs[1])
      path_to_save = path.nil? ? @main_document_path : path
      pdf.save path_to_save
    end

    def ivl_appeal_rights
      join_pdfs [@main_document_path, Rails.root.join('lib/pdf_templates', 'appeals_maine.pdf')]
    end

    def ivl_non_discrimination
      join_pdfs [@main_document_path, Rails.root.join('lib/pdf_templates', 'ivl_non_discrimination.pdf')]
    end

    def ivl_attach_envelope
      join_pdfs [@main_document_path, Rails.root.join('lib/pdf_templates', 'taglines.pdf')]
    end

    def append_verifications_insert(params)
      return Success(true) unless params[:event_key].to_s == 'enrollment_submitted'

      attach_blank_page
      result = document({ key: :outstanding_verifications_insert, entity: params[:application_entity], cover_page: false })
      if result.is_a?(Hash)
        insert_path = result[:document].path
        Success(join_pdfs([@main_document_path, insert_path]))
      else
        Failure("Unable to append verifications insert for family_hbx_id: #{params[:application_entity].family_reference.hbx_id}")
      end
    end

    def append_other_inserts
      attach_blank_page
      attach_blank_page
      ivl_appeal_rights
      # ivl_non_discrimination
      # ivl_attach_envelope
      Success(true)
    end

    def upload_document(document_payload, entity)
      upload = Documents::Upload.new.call(
        resource_id: entity.family_reference.hbx_id,
        title: document_payload[:template][:title],
        file: document_payload[:document],
        user_id: nil,
        subjects: nil
      )

      return Failure("Couldn't upload document for the given payload") unless upload.success?

      Success(upload.success)
    end

    def build_event(payload)
      result = event("events.documents.document_created", attributes: payload.to_h)
      unless Rails.env.test?
        logger.info('-' * 100)
        logger.info(
          "Polypress Reponse Publisher to external systems(enroll),
          event_key: events.documents.document_created, attributes: #{payload.to_h}, result: #{result}"
        )
        logger.info('-' * 100)
      end
      result
    end

    def publish_response(event)
      Success(event.publish)
    end
  end
end
