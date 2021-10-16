# frozen_string_literal: true

module Subscribers
  # Subscriber will receive response payload from enroll and creates ENR document
  class AccountCreatedSubscriber
    include EventSource::Logging
    include ::EventSource::Subscriber[amqp: 'enroll.individual.accounts']

    subscribe(:on_enroll_individual_accounts) do |delivery_info, _metadata, response|
      logger.info "Subscribers::AccountCreatedSubscriber invoked
        on_enroll_individual_accounts with delivery_info: #{delivery_info}, response: #{response}"

      payload = JSON.parse(response, :symbolize_names => true)
      result = Enrollments::GenerateAndPublishDocuments.new.call({ family_hash: payload, event_key: 'account_created' })

      if result.success?
        logger.info "Subscribers::AccountCreatedSubscriber Result: #{result.success} for payload: #{payload}"
      else
        logger.error "Subscribers::AccountCreatedSubscriber Error: #{result.failure} for payload: #{payload}"
      end
      ack(delivery_info.delivery_tag)
    rescue StandardError, SystemStackError => e
      logger.error "Subscribers::AccountCreatedSubscriber Error: #{e.backtrace} for payload: #{payload}"
      ack(delivery_info.delivery_tag)
    end
  end
end
