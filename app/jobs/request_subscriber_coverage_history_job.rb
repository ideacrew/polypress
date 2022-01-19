# frozen_string_literal: true

# Requests coverage information for a subscriber from Glue
class RequestSubscriberCoverageHistoryJob < ApplicationJob
  queue_as :default
  retry_on Timeout::Error, wait: 5.seconds, attempts: 3

  send(:include, ::EventSource::Command)
  send(:include, ::EventSource::Logging)
  RETRY_LIMIT = 5

  def perform(audit_report_datum_id, attempt = 0)
    ard_record = AuditReportDatum.find(audit_report_datum_id)
    if attempt > RETRY_LIMIT
      Rails.logger.info "Retry Limit exceeded for subscriber #{ard_record&.subscriber_id}"
      return
    end

    user_token = PolypressRegistry[:gluedb_integration].setting(:gluedb_user_access_token).item
    service_uri = PolypressRegistry[:gluedb_integration].setting(:gluedb_enrolled_subjects_uri).item
    Reports::RequestCoverageHistoryForSubscriber.new.call({
                                                            audit_report_datum: ard_record,
                                                            service_uri: service_uri,
                                                            user_token: user_token
                                                          })
    generate_pre_audit_report(ard_record&.hios_id)
  rescue StandardError => e
    Rails.logger.info "Failed due to #{e}, and retrying #{attempt} time for subscriber #{ard_record&.subscriber_id}"
    RequestSubscriberCoverageHistoryJob.perform_later(audit_report_datum_id, attempt + 1)
  end

  private

  def generate_pre_audit_report(hios_id)
    total_records = AuditReportDatum.where(hios_id: hios_id).count
    completed_records = AuditReportDatum.where({ hios_id: hios_id,
                                                 status: "completed" }).count
    return unless completed_records >= total_records

    payload = { carrier_hios_id: hios_id }
    event =   event("events.reports.generate_pre_audit_report",
                    attributes: { payload: payload }).success
    unless Rails.env.test?
      logger.info('-' * 100)
      logger.info(
        "Polypress to generate pre audit report, attributes: #{payload.to_h}"
      )
      logger.info('-' * 100)
    end

    event.publish
    Success("Successfully published event to polypress to generate ")
  end
end
