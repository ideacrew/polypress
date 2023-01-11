# frozen_string_literal: true

module Subscribers
  module Families
    module Notices
      module TaxFroms
        # Subscriber will receive response payload from medicaid gateway and generate documents
        class Void1095aNoticeGenerationSubscriber
          include EventSource::Logging
          include ::EventSource::Subscriber[amqp: 'edi_gateway.families.notices.tax_forms.void1095a']

          subscribe(:on_requested) do |delivery_info, _metadata, response|

            routing_key = delivery_info[:routing_key]
            logger.info "Polypress: invoked Void1095aNoticeGenerationSubscriber with delivery_info: #{delivery_info} routing_key: #{routing_key}"

            payload = JSON.parse(response, symbolize_names: true)
            # event_key = routing_key.split('.').last

            result =
              PolicyTaxHouseholds::GenerateAndPublishTaxDocuments.new.call(
                { payload: payload, event_key: routing_key }
              )
            if result.success?
              logger.info "Polypress: Catastrophic1095aNoticeGenerationSubscriber; acked for #{routing_key}"
            else
              errors = if result.is_a?(String)
                         result
                       elsif result.failure.is_a?(String)
                         result.failure
                       else
                         result.failure.errors.to_h
                       end
              logger.error(
                "Polypress: Catastrophic1095aNoticeGenerationSubscriber_error;
                    nacked due to:#{errors}; for routing_key: #{routing_key}, payload: #{payload}"
              )
            end
            ack(delivery_info.delivery_tag)
          rescue StandardError, SystemStackError => e
            logger.error(
              "Polypress: Void1095aNoticeGenerationSubscriber_error: nacked due to backtrace:
                #{e.backtrace}; for routing_key: #{routing_key}, response: #{response}"
            )
            ack(delivery_info.delivery_tag)
          end
        end
      end
    end
  end
end
