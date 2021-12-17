# frozen_string_literal: true

module Publishers
  module Reports
    # Publisher will send payload with carrier id and year to EDI Gateway
    class GeneratePreAuditReportPublisher
      # TODO: enable below after eventsource initializer is updated acccordingly to acaentities async_api yml files
      include ::EventSource::Publisher[amqp: 'poylpress.report_generation']

      register_event 'generate_pre_audit_report'
    end
  end
end
