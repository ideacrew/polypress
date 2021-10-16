# frozen_string_literal: true

module Subscribers
  # Subscriber will receive response payload from medicaid gateway and generate documents
  class DeterminationSubscriber
    include EventSource::Logging
    include ::EventSource::Subscriber[amqp: 'magi_medicaid.mitc.eligibilities']

    subscribe(
      :on_magi_medicaid_mitc_eligibilities
    ) do |delivery_info, _metadata, response|
      routing_key = delivery_info[:routing_key]
      logger.info "Polypress: invoked on_magi_medicaid_mitc_eligibilities with delivery_info: #{delivery_info} routing_key: #{routing_key}"
      payload = JSON.parse(response, symbolize_names: true)
      # event_key = routing_key.split('.').last
      results =
        MagiMedicaid::GenerateAndPublishEligibilityDocuments.new.call(
          { payload: payload, event_key: routing_key }
        )
      if results.all?(&:success)
        logger.info "Polypress: polypress_eligibility_determination_subscriber_message; acked for #{routing_key}"
      else
        results
          .map(&:failure)
          .compact
          .each do |result|
            errors =
              if result.is_a?(String)
                result
              elsif result.failure.is_a?(String)
                result.failure
              else
                result.failure.errors.to_h
              end
            logger.error(
              "Polypress: polypress_eligibility_determination_subscriber_error;
            nacked due to:#{errors}; for routing_key: #{routing_key}, payload: #{payload}"
            )
          end
      end
      ack(delivery_info.delivery_tag)
    rescue StandardError, SystemStackError => e
      logger.error(
        "Polypress: polypress_eligibility_determination_subscriber_error: nacked due to backtrace:
        #{e.backtrace}; for routing_key: #{routing_key}, response: #{response}"
      )
      ack(delivery_info.delivery_tag)
    end
  end
end
