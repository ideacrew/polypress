# frozen_string_literal: true

module Subscribers
  module Reports
    # Subscribe events for report generations
    class PoliciesForSubscriberReceivedSubscriber
      include ::EventSource::Subscriber[amqp: 'edi.reports.coverage_history_for_subscriber']

      # rubocop:disable Lint/RescueException
      # rubocop:disable Style/LineEndConcatenation
      # rubocop:disable Style/StringConcatenation
      subscribe(:on_receive_coverage_history_for_subscriber) do |delivery_info, _properties, payload|
        # Sequence of steps that are executed as single operation
        event_key = "coverage_history_for_subscribe_received"
        correlation_id = properties.correlation_id

        result = Reports::StoreCoverageHistoryAndGenerateReport.new.call({ event_key: event_key,
                                                                           payload: payload,
                                                                           correlation_id: correlation_id })

        if result.success?
          logger.info(
            "OK: :on_receive_subscribers_list successful and acked"
          )
          ack(delivery_info.delivery_tag)
        else
          logger.error(
            "Error: :on_receive_subscribers_list; nacked due to:#{result.inspect}"
          )
          nack(delivery_info.delivery_tag)
        end

      rescue Exception => e
        logger.error(
          "Exception: :on_receive_subscribers_list\n Exception: #{e.inspect}" +
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
