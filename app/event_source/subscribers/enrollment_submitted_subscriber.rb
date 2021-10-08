# frozen_string_literal: true

module Subscribers
  # Subscriber will receive response payload from enroll and creates ENR document
  class EnrollmentSubmittedSubscriber
    include EventSource::Logging
    include ::EventSource::Subscriber[amqp: 'enroll.individual.enrollments']

    subscribe(:on_enroll_individual_enrollments) do |delivery_info, _metadata, response|
      logger.info "Polypress invoked on_enroll_individual_enrollments with delivery_info: #{delivery_info}, response: #{response}"

      payload = JSON.parse(response, :symbolize_names => true)
      result = Enrollments::GenerateAndPublishDocuments.new.call({ family_hash: payload, event_key: delivery_info[:routing_key] })

      if result.success?
        logger.info "Polypress polypress_individual_enrollment_info Result: #{result.success} for payload: #{payload}"
        ack(delivery_info.delivery_tag)
      else
        logger.error "Polypress polypress_individual_enrollment_error: #{result.failure} for payload: #{payload}"
        nack(delivery_info.delivery_tag)
      end
    rescue StandardError => e
      nack(delivery_info.delivery_tag)
      logger.error "Polypress polypress_individual_enrollment_error: #{e.backtrace} for payload: #{payload}"
    end
  end
end
