# frozen_string_literal: true

module Subscribers
  module Families
    module Notices
      module TaxForms
        # Subscriber will receive tax_form1095a_payload from EDI gateway and generate documents
        class Tax1095aNoticeGenerationSubscriber
          include EventSource::Logging
          include ::EventSource::Subscriber[amqp: 'edi_gateway.families.tax_form1095a']

          subscribe(:on_edi_gateway_families_tax_form1095a) do |delivery_info, _metadata, response|
            routing_key = delivery_info[:routing_key]
            logger.info "Polypress: invoked Tax1095aNoticeGenerationSubscriber with delivery_info:
                            #{delivery_info} routing_key: #{routing_key}"
            payload = JSON.parse(response, symbolize_names: true)

            result = ::Individuals::PolicyTaxHouseholds::GenerateAndPublishTaxDocuments.new.call(
              { payload: payload[:cv3_family], event_key: routing_key }
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
