class RequestSubscriberCoverageHistoryJob < ApplicationJob
  queue_as :default

  def perform(audit_report_datum_id)
    ard_record = AuditReportDatum.find(audit_report_datum_id)
    user_token = PolypressRegistry[:gluedb_integration].setting(:gluedb_user_access_token).item # lookup user token
    service_uri = PolypressRegistry[:gluedb_integration].setting(:gluedb_enrolled_subjects_uri).item # lookup service url
    result = Reports::RequestCoverageHistoryForSubscriber.new.call({
      audit_report_datum: audit_report_datum,
      service_uri: service_uri,
      user_token: user_token
    })
    # Now here we're gonna check if our count of completed records
    # for audit report datum is all of them, and if so gen the report.
    total_records = AuditReportDatum.where(hios_id: audit_report_datum.hios_id).count
    completed_records = AuditReportDatum.where({
      hios_id: audit_report_datum.hios_id,
      status: "completed"
    }).count
    if completed_records >= total_records
      # Complete the report
      payload = { carrier_hios_id: audit_report_datum.hios_id }
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
end
