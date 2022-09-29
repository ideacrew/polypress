# frozen_string_literal: true

module Subscribers
  module Applications
    module AptcCsrCreditEligibilities
      module Renewals
        # Subscriber will receive response payload from medicaid gateway and generate documents
        class RenewalsSubscriber
          include EventSource::Logging
          include ::EventSource::Subscriber[amqp: 'enroll.applications.aptc_csr_credits.renewals.notice']

          subscribe(
            :on_enroll_applications_aptc_csr_credits_renewals_notice
          ) do |delivery_info, _metadata, response|
            routing_key = delivery_info[:routing_key]
            logger.info "Polypress: invoked RenewalsSubscriber with delivery_info: #{delivery_info} routing_key: #{routing_key}"

            payload = JSON.parse(response, symbolize_names: true)
            # event_key = routing_key.split('.').last
            results =
              MagiMedicaid::GenerateAndPublishEligibilityDocuments.new.call(
                { payload: payload, event_key: routing_key }
              )
            if results.all?(&:success)
              logger.info "Polypress: RenewalsSubscriber; acked for #{routing_key}"
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
                    "Polypress: RenewalsSubscriber_error;
                  nacked due to:#{errors}; for routing_key: #{routing_key}, payload: #{payload}"
                  )
                end
            end
            ack(delivery_info.delivery_tag)
          rescue StandardError, SystemStackError => e
            logger.error(
              "Polypress: RenewalsSubscriber_error: nacked due to backtrace:
              #{e.backtrace}; for routing_key: #{routing_key}, response: #{response}"
            )
            ack(delivery_info.delivery_tag)
          end
        end
      end
    end
  end
end