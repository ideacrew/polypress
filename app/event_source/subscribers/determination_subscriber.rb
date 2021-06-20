# frozen_string_literal: true

module Subscribers
  # Subscriber will receive response payload from medicaid gateway and generate documents
  class DeterminationSubscriber
    include EventSource::Logging
    include ::EventSource::Subscriber[amqp: 'magi_medicaid.mitc.eligibilities']

    subscribe(:on_determined_aptc_eligible) do |delivery_info, _metadata, _response|
      logger.info "Polypress: invoked on_determined_aptc_eligible with #{delivery_info}"
    end
    subscribe(:on_determined_medicaid_chip_eligible) do |delivery_info, _metadata, _response|
      logger.info "Polypress: invoked on_determined_medicaid_chip_eligible with #{delivery_info}"
    end
    subscribe(:on_determined_totally_ineligible) do |delivery_info, _metadata, _response|
      logger.info "Polypress: invoked on_determined_totally_ineligible with #{delivery_info}"
    end
    subscribe(:on_determined_magi_medicaid_eligible) do |delivery_info, _metadata, response|
      logger.info "Polypress: invoked on_determined_magi_medicaid_eligible with #{delivery_info}"
      payload = JSON.parse(response, :symbolize_names => true)
      result = MagiMedicaid::PublishUqhpEligibleDocument.new.call({ application: payload, event_key: 'determined_medicaid_eligible' })
      if result.success?
        ack(delivery_info.delivery_tag)
        logger.info "polypress_eligibility_determination_subscriber_message; acked"
      else
        errors = result.failure.errors.to_h
        nack(delivery_info.delivery_tag)
        logger.debug "polypress_eligibility_determination_subscriber_message; nacked due to:#{errors}; payload: #{payload}"
      end
    rescue StandardError => e
      nack(delivery_info.delivery_tag)
      logger.debug "polypress_eligibility_determination_subscriber_error: baacktrace: #{e.backtrace}; nacked; payload: #{payload}"
    end
    subscribe(:on_determined_uqhp_eligible) do |delivery_info, _metadata, _response|
      logger.info "Polypress: invoked on_determined_uqhp_eligible with #{delivery_info}"
    end
    subscribe(:on_determined_mixed_determination) do |delivery_info, _metadata, _response|
      logger.info "Polypress: invoked on_determined_mixed_determination with #{delivery_info}"
    end
  end
end