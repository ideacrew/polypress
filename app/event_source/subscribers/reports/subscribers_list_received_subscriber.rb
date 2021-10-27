# frozen_string_literal: true

module Subscribers
  module Reports
    # Subscribe events for report generations
    class SubscribersListReceivedSubscriber
      include ::EventSource::Subscriber[amqp: 'edi.reports.subscribers_list']

      # rubocop:disable Lint/RescueException
      # rubocop:disable Style/LineEndConcatenation
      # rubocop:disable Style/StringConcatenation
      subscribe(:on_receive_subscribers_list) do |delivery_info, properties, _payload|
        # Sequence of steps that are executed as single operation
        event_key = "subscribers_list_received"
        correlation_id = properties&.correlation_id

        result = Reports::RequestCoverageHistoryForSubscriber.new.call({ event_key: event_key,
                                                                         correlation_id: correlation_id,
                                                                         payload: payload })

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
