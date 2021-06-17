# frozen_string_literal: true

module Subscribers
  # Subscriber will receive response payload from medicaid gateway and generate documents
  class DeterminationSubscriber
    include EventSource::Logging
    include ::EventSource::Subscriber[amqp: 'magi_medicaid.mitc.eligibilities']

    subscribe(:on_determined_aptc_eligible) do |delivery_info, _metadata, _payload|
      logger.info "invoked on_determined_aptc_eligible with #{delivery_info}"
    end
    subscribe(:on_determined_medicaid_chip_eligible) do |delivery_info, _metadata, _payload|
      logger.info "invoked on_determined_medicaid_chip_eligible with #{delivery_info}"
    end
    subscribe(:on_determined_totally_ineligible) do |delivery_info, _metadata, _payload|
      logger.info "invoked on_determined_totally_ineligible with #{delivery_info}"
    end
    subscribe(:on_determined_magi_medicaid_eligible) do |delivery_info, _metadata, _payload|
      logger.info "invoked on_determined_magi_medicaid_eligible with #{delivery_info}"
    end
    subscribe(:on_determined_uqhp_eligible) do |delivery_info, _metadata, _payload|
      logger.info "invoked on_determined_uqhp_eligible with #{delivery_info}"
    end
    subscribe(:on_determined_mixed_determination) do |delivery_info, _metadata, _payload|
      logger.info "invoked on_determined_mixed_determination with #{delivery_info}"
    end
  end
end