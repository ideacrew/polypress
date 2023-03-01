# frozen_string_literal: true

module Subscribers
  module Families
    module Notices
      module TaxForms
        # Subscriber will receive payload from FDSH gateway and generate documents
        class Tax1095aNoticeGenerationSubscriber
          include EventSource::Logging
          include ::EventSource::Subscriber[amqp: 'fdsh_gateway.irs1095as']

          subscribe(:on_fdsh_gateway_irs1095as) do |delivery_info, _metadata, response|
            routing_key = delivery_info[:routing_key]
            logger.info "Polypress: invoked Tax1095aNoticeGenerationSubscriber with delivery_info:
                            #{delivery_info} routing_key: #{routing_key}"
            payload = JSON.parse(response, symbolize_names: true)

            result = ::Individuals::PolicyTaxHouseholds::GenerateAndPublishTaxDocuments.new.call(
              { family_hash: payload, event_key: routing_key }
            )
            if result.success?
              logger.info "Polypress: Tax1095aNoticeGenerationSubscriber; acked for #{routing_key}"
            else
              errors = if result.is_a?(String)
                         result
                       elsif result.failure.is_a?(String)
                         result.failure
                       else
                         result.failure.errors.to_h
                       end
              logger.error(
                "Polypress: Tax1095aNoticeGenerationSubscriber_error;
                      nacked due to:#{errors}; for routing_key: #{routing_key}, payload: #{payload}"
              )
            end
            ack(delivery_info.delivery_tag)
          rescue StandardError, SystemStackError => e
            logger.error(
              "Polypress: Tax1095aNoticeGenerationSubscriber_error: nacked due to backtrace:
                  #{e.backtrace}; for routing_key: #{routing_key}, response: #{response}"
            )
            ack(delivery_info.delivery_tag)
          end
        end
      end
    end
  end
end
