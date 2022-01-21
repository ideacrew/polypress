# frozen_string_literal: true

# Requests coverage information for a subscriber from Glue
class RequestCoverageHistoryForRcnoJob < ApplicationJob
  queue_as :default
  retry_on Timeout::Error, wait: 5.seconds, attempts: 3

  RETRY_LIMIT = 5

  def perform(audit_report_datum_id, attempt = 0)
    @logger = Logger.new("#{Rails.root}/log/recon_report.log")
    ard_record = AuditReportDatum.find(audit_report_datum_id)
    if attempt > RETRY_LIMIT
      @logger.info "Retry Limit exceeded for subscriber #{ard_record&.subscriber_id}"
      return
    end

    user_token = PolypressRegistry[:gluedb_integration].setting(:gluedb_user_access_token).item
    service_uri = PolypressRegistry[:gluedb_integration].setting(:gluedb_enrolled_subjects_uri).item
    result = Reports::RequestCoverageHistoryForSubscriber.new.call({
                                                                     audit_report_datum: ard_record,
                                                                     service_uri: service_uri,
                                                                     user_token: user_token,
                                                                     logger: @logger
                                                                   })
    if result.success?
      generate_rcno_report(ard_record&.hios_id)
    else
      @logger.info "Failed due to #{result.failure}, and retrying #{attempt} time for subscriber #{ard_record&.subscriber_id}"
      RequestCoverageHistoryForRcnoJob.perform_later(audit_report_datum_id, attempt + 1)
    end
  end

  private

  def generate_rcno_report(hios_id)
    total_records = AuditReportDatum.where(hios_id: hios_id, report_type: "rcno").count
    completed_records = AuditReportDatum.where({ hios_id: hios_id,
                                                 report_type: "rcno",
                                                 status: "completed" }).count
    return unless completed_records >= total_records

    payload = { carrier_hios_id: hios_id }

    Reports::GenerateRcnoReport.new.call({ :payload => { payload: payload }.to_json })
  end
end
