# frozen_string_literal: true

# Requests coverage information for a subscriber from Glue
class RequestCoverageHistoryForRcnoJob < ApplicationJob
  queue_as :default
  retry_on Timeout::Error, wait: 5.seconds, attempts: 3

  def perform(audit_report_datum_id)
    ard_record = AuditReportDatum.find(audit_report_datum_id)
    user_token = PolypressRegistry[:gluedb_integration].setting(:gluedb_user_access_token).item
    service_uri = PolypressRegistry[:gluedb_integration].setting(:gluedb_enrolled_subjects_uri).item
    Reports::RequestCoverageHistoryForSubscriber.new.call({
                                                            audit_report_datum: ard_record,
                                                            service_uri: service_uri,
                                                            user_token: user_token
                                                          })
    generate_pre_audit_report(ard_record.hios_id)
  end

  private

  def generate_pre_audit_report(hios_id)
    total_records = AuditReportDatum.where(hios_id: hios_id).count
    completed_records = AuditReportDatum.where({ hios_id: hios_id,
                                                 report_type: "rcno",
                                                 status: "completed" }).count
    return unless completed_records >= total_records

    payload = { carrier_hios_id: hios_id }

    Reports::GenerateRcnoReport.new.call({ :payload => { payload: payload }.to_json })
  end
end
