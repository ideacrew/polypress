# frozen_string_literal: true

# This class represents single run of the report,
# and helps connect all the subsequent subscriber child records
class AuditReportDatum
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :audit_report_execution

  field :subscriber_id, type: String
  field :status, type: String
  field :payload, type: String
end
