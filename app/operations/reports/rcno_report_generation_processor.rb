# frozen_string_literal: true

module Reports
  # Start rcno report generation processor
  class RcnoReportGenerationProcessor
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    def call(params)
      valid_params = yield validate(params)
      rcni_file_path = yield fetch_rcni_file_path(valid_params[:hios_id])
      fetch_and_store_coverage_history(rcni_file_path, valid_params[:hios_id])
      Success(true)
    end

    private

    def validate(params)
      Failure("Unable to find hios id") if params[:hios_id].blank?
      unless File.exist?("#{Rails.root}/RCNI_#{params[:hios_id]}")
        Failure("Unable to find RCNI file for carrier hios_id #{params[:hios_id]}, please upload one")
      end

      Success(params)
    end

    def fetch_rcni_file_path(hios_id)
      if File.exist?("#{Rails.root}/RCNI_#{hios_id}.txt")
        Success("#{Rails.root}/RCNI_#{hios_id}.txt")
      else
        Failure("Unable to find rcni file for hios id #{hios_id}")
      end
    end

    def fetch_and_store_coverage_history(rcni_file_path, hios_id)
      File.readlines(rcni_file_path, chomp: true).each do |line|
        result = line.split("|")
        next if result[0] != "01"

        create_audit_datum_and_fetch_data(result[16], hios_id)
      end
    end

    def create_audit_datum_and_fetch_data(subscriber_id, hios_id)
      audit_records = AuditReportDatum.where(hios_id: hios_id, subscriber_id: subscriber_id, report_type: "rcno")
      return if audit_records.present?

      audit_record = AuditReportDatum.create!(report_type: "rcno", subscriber_id: subscriber_id,
                                              status: "pending", hios_id: hios_id)
      fetch_coverage_history(audit_record)
    end

    def fetch_coverage_history(audit_record)
      if Rails.env.production?
        RequestCoverageHistoryForRcnoJob.perform_later(audit_record.id.to_s)
      else
        manually_fetch_coverage_history(audit_record.id.to_s)
      end
    end

    def manually_fetch_coverage_history(audit_record)
      logger = Logger.new("#{Rails.root}/log/rcno_report_generation_#{Date.today.strftime('%Y_%m_%d')}.log")
      ard_record = AuditReportDatum.find(audit_record)
      logger.info "record processing by queue for subscriber #{ard_record.subscriber_id} with status #{ard_record.status}"
      user_token = PolypressRegistry[:gluedb_integration].setting(:gluedb_user_access_token).item
      service_uri = PolypressRegistry[:gluedb_integration].setting(:gluedb_enrolled_subjects_uri).item
      Reports::RequestCoverageHistoryForSubscriber.new.call({
                                                              audit_report_datum: ard_record,
                                                              service_uri: service_uri,
                                                              user_token: user_token
                                                            })
      logger.info "record payload from glue #{ard_record.subscriber_id} with status #{ard_record.status}"
    end
  end
end