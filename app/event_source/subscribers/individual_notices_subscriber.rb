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

      routing_key = delivery_info[:routing_key]
      template_model =
        Templates::TemplateModel.by_subscriber(event_name: routing_key).first

      # find notice template by routing key
      # call operation with template and payload to generate notice document
      # publish document to a preconfigured publisher

      payload = JSON.parse(response, symbolize_names: true)
      result =
        Individuals::GenerateNotice.new.call(
          { template_model: template_model, payload: payload }
        )

      if result.success?
        logger.info "Subscribers::IndividualNoticesSubscriber Result: #{result.success} for payload: #{payload}"
        ack(delivery_info.delivery_tag)
      else
        logger.error "Subscribers::IndividualNoticesSubscriber Error: #{result.failure} for payload: #{payload}"
        nack(delivery_info.delivery_tag)
      end
    rescue StandardError => e
      nack(delivery_info.delivery_tag)
      logger.error "Subscribers::IndividualNoticesSubscriber Error: #{e.backtrace} for payload: #{payload}"
    end
  end
end
