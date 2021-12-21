class RequestSubscriberCoverageHistoryJob < ApplicationJob
  queue_as :default

  def perform(audit_report_datum_id)
    ard_record = AuditReportDatum.find(audit_report_datum_id)
    user_token = "" # lookup user token
    service_uri = "" # lookup service url
    result = Reports::RequestCoverageHistoryForSubscriber.new.call({
      audit_report_datum: audit_report_datum,
      service_uri: service_uri,
      user_token: user_token
    })
    # Now here we're gonna check if our count of completed records
    # for audit report datum is all of them, and if so gen the report.
  end
end
