# frozen_string_literal: true

module Subscribers
  # Subscriber will receive response payload from medicaid gateway and generate documents
  class DeterminationSubscriber
    include EventSource::Logging
    include ::EventSource::Subscriber[amqp: 'magi_medicaid.mitc.eligibilities']

    subscribe(:on_magi_medicaid_mitc_eligibilities) do |delivery_info, _metadata, response|
      routing_key = delivery_info[:routing_key]
      logger.info "Polypress: invoked on_magi_medicaid_mitc_eligibilities with delivery_info: #{delivery_info} routing_key: #{routing_key}"
      payload = JSON.parse(response, :symbolize_names => true)
      event_key = routing_key.split('.').last
      results = MagiMedicaid::GenerateAndPublishEligibilityDocuments.new.call({ application: payload, event_key: event_key })
      if results.all?(&:success)
        ack(delivery_info.delivery_tag)
        logger.info "Polypress: polypress_eligibility_determination_subscriber_message; acked for #{routing_key}"
      else
        results.map(&:failure).compact.each do |result|
          errors = result.failure.errors.to_h
          logger.error(
            "Polypress: polypress_eligibility_determination_subscriber_error;
            nacked due to:#{errors}; for routing_key: #{routing_key}, payload: #{payload}"
          )
        end
        nack(delivery_info.delivery_tag)
      end
    rescue StandardError => e
      nack(delivery_info.delivery_tag)
      logger.error(
        "Polypress: polypress_eligibility_determination_subscriber_error: nacked due to backtrace:
        #{e.backtrace}; for routing_key: #{routing_key}, response: #{response}"
      )
    end
  end
end
