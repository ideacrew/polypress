# frozen_string_literal: true

# This class represents single run of the report,
# and helps connect all the subsequent subscriber child records
class AuditReportDatum
  include Mongoid::Document
  include Mongoid::Timestamps

  field :subscriber_id, type: String
  field :status, type: String
  field :correlation_id, type: String
  field :payload, type: String
end
