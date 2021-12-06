# frozen_string_literal: true

FactoryBot.define do
  factory :audit_report_execution do
    report_kind { 'pre_audit'}
    status { 'pending'}
    audit_year { Date.today.year }
    hios_id { '12345' }
  end
end