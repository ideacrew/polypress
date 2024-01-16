# frozen_string_literal: true

module Subscribers
  module Families
    module Notices
      module TaxForms
        # Subscriber will receive payload from EDI gateway and generate 1095a notices
        class Cap1095aNoticeGenerationSubscriber
          include EventSource::Logging
          include ::EventSource::Subscriber[amqp: 'edi_gateway.families.tax_form1095a']

          subscribe(:on_catastrophic_payload_generated) do |delivery_info, _metadata, response|
            routing_key = delivery_info[:routing_key]
            logger.info "Polypress: invoked Cap1095aNoticeGenerationSubscriber with delivery_info:
                              #{delivery_info} routing_key: #{routing_key}"
            payload = JSON.parse(response, symbolize_names: true)

            result = ::Individuals::PolicyTaxHouseholds::GenerateAndPublishTaxDocuments.new.call(
              { family_hash: payload, event_key: routing_key }
            )
            if result.success?
              logger.info "Polypress: Cap1095aNoticeGenerationSubscriber; successfully generated notice for cap_1095a"
              logger.info "Polypress: Cap1095aNoticeGenerationSubscriber; acked for #{routing_key}"
            else
              errors = if result.is_a?(String)
                         result
                       elsif result.failure.is_a?(String)
                         result.failure
                       else
                         result.failure.errors.to_h
                       end
              logger.error(
                "Polypress: Cap1095aNoticeGenerationSubscriber_error;
                        nacked due to:#{errors}; for routing_key: #{routing_key}, payload: #{payload}"
              )
            end
            ack(delivery_info.delivery_tag)
          rescue StandardError, SystemStackError => e
            logger.error(
              "Polypress: Cap1095aNoticeGenerationSubscriber_error: nacked due to backtrace:
                    #{e.backtrace}; for routing_key: #{routing_key}, response: #{response}"
            )
            ack(delivery_info.delivery_tag)
          end
        end
      end
    end
  end
end
