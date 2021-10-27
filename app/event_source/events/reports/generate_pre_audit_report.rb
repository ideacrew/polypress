# frozen_string_literal: true

module Events
  module Reports
    # Will register publisher event for Polypress
    class GeneratePreAuditReport < EventSource::Event
      publisher_path 'publishers.reports.generate_pre_audit_report_publisher'

    end
  end
end