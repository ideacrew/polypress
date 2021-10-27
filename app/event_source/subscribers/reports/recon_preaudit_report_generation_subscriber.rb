# frozen_string_literal: true

module Subscribers
  module Reports
    # Subscribe events for report generations
    class ReconPreauditReportGenerationSubscriber
      include ::EventSource::Subscriber[amqp: 'enroll.reports.recon_preaudit']

      # rubocop:disable Lint/RescueException
      # rubocop:disable Style/LineEndConcatenation
      # rubocop:disable Style/StringConcatenation
      subscribe(:on_generate_recon_preaudit_report) do |delivery_info, _properties, _payload|
        # Sequence of steps that are executed as single operation
        event_key = "preaudit_generation_report"

        result = Reports::ReconPreAuditProcessor.new.call({ event_key: event_key })

        if result.success?
          logger.info(
            "OK: :on_generate_recon_preaudit_report successful and acked"
          )
          ack(delivery_info.delivery_tag)
        else
          logger.error(
            "Error: :on_generate_recon_preaudit_report; nacked due to:#{result.inspect}"
          )
          nack(delivery_info.delivery_tag)
        end

      rescue Exception => e
        logger.error(
          "Exception: :on_generate_recon_preaudit_report\n Exception: #{e.inspect}" +
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
