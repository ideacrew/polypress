# frozen_string_literal: true

module Subscribers
  # Subscriber will receive response payload from enroll and creates ENR document
  class EnrollmentSubmittedSubscriber
    include EventSource::Logging
    include ::EventSource::Subscriber[amqp: 'enroll.individual.enrollments']

    subscribe(:on_enroll_individual_enrollment) do |delivery_info, _metadata, response|
      logger.info "Polypress invoked on_enroll_individual_enrollment with delivery_info: #{delivery_info}, response: #{response}"

      payload = JSON.parse(response, :symbolize_names => true)
      result = Enrollments::GenerateAndPublishDocuments.new.call({ family_hash: payload, event_key: 'enrollment_submitted' })

      if result.success?
        ack(delivery_info.delivery_tag)
        logger.info "Polypress polypress_individual_enrollment_info Result: #{result.success} for payload: #{payload}"
      else
        nack(delivery_info.delivery_tag)
        logger.error "Polypress polypress_individual_enrollment_error: #{result.failure.message} for payload: #{payload}"
      end
    rescue StandardError => e
      nack(delivery_info.delivery_tag)
      logger.error "Polypress polypress_individual_enrollment_error: #{e.backtrace} for payload: #{payload}"
    end
  end
end
