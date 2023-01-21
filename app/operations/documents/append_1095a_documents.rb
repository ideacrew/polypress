# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Documents
  # Operation to create document with inserts
  class Append1095aDocuments
    include Dry::Monads[:result, :do]
    include Dry::Monads[:try]
    include ::EventSource::Command
    include ::EventSource::Logging

    IRS_LOCAL_1095A_FOLDER = 'aws/irs_1095a'

    # @param [Hash] AcaEntities::Families::Family
    def call(params)
      _create_folder = yield create_folder
      _process = yield process(params[:payload])
      _combine_tax_documents = yield combine_tax_documents
      _clear = yield clear_individual_documents

      Success(@path)
    end

    private

    def create_folder
      Success(FileUtils.mkdir_p(Rails.root.join('..', IRS_LOCAL_1095A_FOLDER)))
    end

    def process(family_hash)
      @family_hbx_id = family_hash[:hbx_id]
      family_hash[:households].each do |household|
        household[:insurance_agreements].each do |insurance_agreement|
          insurance_agreement[:insurance_policies].each do |insurance_policy|
            insurance_policy[:aptc_csr_tax_households].each do |aptc_csr_tax_household|
              @recipient = recipient(aptc_csr_tax_household, insurance_agreement, family_hash)

              generate_pdf(
                tax_household: aptc_csr_tax_household,
                insurance_agreement: insurance_agreement,
                insurance_policy: insurance_policy
              )
            end
          end
        end
      rescue StandardError => e
        Rails.logger.error("unable to generate 1095As for the family hbx_id #{@family_hbx_id} due to #{e.inspect}")
        Failure("unable to generate 1095As for the family hbx_id #{@family_hbx_id} due to #{e.inspect}")
      end
      Success(true)
    end

    def generate_pdf(tax_household:, insurance_agreement:, insurance_policy:)
      irs_report = IrsYearlyPdfReport.new(
        tax_household: tax_household,
        recipient: @recipient,
        insurance_agreement: insurance_agreement,
        insurance_policy: insurance_policy
      )
      irs_report.process

      @folder_path = Rails.root.join('..', IRS_LOCAL_1095A_FOLDER, @family_hbx_id.to_s)
      FileUtils.mkdir_p @folder_path
      @absolute_file_path = "#{@folder_path}/#{@family_hbx_id}_#{DateTime.now.strftime('%Y%m%d%H%M%S%L')}.pdf"

      irs_report.render_file(@absolute_file_path)
    end

    def combine_tax_documents
      files = Dir["#{@folder_path}/*"].select { |path| File.file?(path) }
      pdf = nil

      files.each do |file|
        if pdf.nil?
          pdf = CombinePDF.load(file)
        else
          pdf << CombinePDF.load(file)
        end
      end

      @path = Rails.root.join('..', IRS_LOCAL_1095A_FOLDER, "#{@recipient[:person][:hbx_id]}_1095A_#{DateTime.now.strftime('%Y%m%d%H%M%S')}.pdf")
      if pdf.save(@path)
        Success(@path)
      else
        Failure("Unable to combine/save 1095A documents")
      end
    end

    def clear_individual_documents
      Success(FileUtils.remove_dir(@folder_path, true))
    end

    def recipient(aptc_csr_tax_household, insurance_agreement, family_hash)
      tax_filers = aptc_csr_tax_household[:covered_individuals].select { |covered_individual| covered_individual[:filer_status] == 'tax_filer' }

      tax_filer =
        if tax_filers.count == 1
          tax_filers[0]
        elsif tax_filers.count > 1
          tax_filers.detect { |tx_filer| tx_filer[:relation_with_primary] == 'self' }
        end

      return tax_filer if tax_filer.present?

      family_hash[:family_members].detect do |family_member|
        family_member[:person][:hbx_id] == insurance_agreement[:contract_holder][:hbx_id]
      end
    end
  end
end
