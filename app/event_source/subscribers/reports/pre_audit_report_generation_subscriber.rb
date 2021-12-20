# frozen_string_literal: true

module Subscribers
  module Reports
    # Subscribe events for report generations
    class PreAuditReportGenerationSubscriber
      include ::EventSource::Subscriber[amqp: 'polypress.report_generation']

      # rubocop:disable Lint/RescueException
      # rubocop:disable Style/LineEndConcatenation
      # rubocop:disable Style/StringConcatenation
      subscribe(:on_generate_pre_audit_report) do |delivery_info, _properties, payload|
        # Sequence of steps that are executed as single operation
        event_key = "generate_pre_audit_report"

        result = ::Reports::GeneratePreAuditReport.new.call({ event_key: event_key,
                                                              payload: payload })

        if result.success?
          logger.info(
            "OK: :on_receive_report_generation_event successful and acked"
          )
          ack(delivery_info.delivery_tag)
        else
          logger.error(
            "Error: :on_receive_report_generation_event; nacked due to:#{result.inspect}"
          )
          nack(delivery_info.delivery_tag)
        end

      rescue Exception => e
        logger.error(
          "Exception: :on_receive_report_generation_event\n Exception: #{e.inspect}" +
            "\n Backtrace:\n" + e.backtrace.join("\n")
        )
        nack(delivery_info.delivery_tag)
      end
      # rubocop:enable Lint/RescueException
      # rubocop:enable Style/LineEndConcatenation
      # rubocop:enable Style/StringConcatenation
    end
  end
end
