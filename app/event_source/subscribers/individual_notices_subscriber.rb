# frozen_string_literal: true

module Subscribers
  # Subscriber will receive response payload from enroll and creates ENR document
  class IndividualNoticesSubscriber
    include EventSource::Logging
    include ::EventSource::Subscriber[amqp: 'enroll.individual.notices']

    subscribe(
      :on_enroll_individual_notices
    ) do |delivery_info, _metadata, response|
      logger.info "Subscribers::IndividualNoticesSubscriber invoked
        on_enroll_individual_notices with delivery_info: #{delivery_info}, response: #{response}"

      # find notice template by routing key
      # call operation with template and payload to generate notice document
      # publish document to a preconfigured publisher

      payload = JSON.parse(response, symbolize_names: true)
      result =
        MagiMedicaid::GenerateAndPublishEligibilityDocuments.new.call(
          { event_key: delivery_info[:routing_key], payload: payload }
        )

      if result.success?
        logger.info "Subscribers::IndividualNoticesSubscriber Result: #{result.success} for payload: #{payload}"
      else
        logger.error "Subscribers::IndividualNoticesSubscriber Error: #{result.failure} for payload: #{payload}"
      end
      ack(delivery_info.delivery_tag)
    rescue StandardError, SystemStackError => e
      logger.error "Subscribers::IndividualNoticesSubscriber Error: #{e.backtrace} for payload: #{payload}"
      ack(delivery_info.delivery_tag)
    end
  end
end
