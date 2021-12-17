# frozen_string_literal: true

# This class represents single run of the report,
# and helps connect all the subsequent subscriber child records
class AuditReportExecution
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :audit_report_datum

  field :report_kind, type: String
  field :status, type: String
  field :record_count, type: String
  field :audit_year, type: String
  field :hios_id, type: String

  index({ status: 1 })
  index({ correlation_id: 1 })
  index({ hios_id: 1, audit_year: 1 })
end
