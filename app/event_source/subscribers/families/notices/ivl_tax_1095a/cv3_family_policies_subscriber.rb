# frozen_string_literal: true

module Subscribers
  module Families
    module Notices
      module IvlTax1095a
        # Subscriber will receive response payload from medicaid gateway and generate documents
        class Cv3FamilyPoliciesSubscriber
          include EventSource::Logging
          include ::EventSource::Subscriber[amqp: 'edi_gateway.families.notices.ivl_tax_1095a']

          subscribe(:on_edi_gateway_families_notices_ivl_tax_1095a) do |delivery_info, _metadata, response|
            routing_key = delivery_info[:routing_key]
            logger.info "Polypress: invoked Cv3FamilyPoliciesSubscriber with delivery_info: #{delivery_info} routing_key: #{routing_key}"

            payload = JSON.parse(response, symbolize_names: true)
            # event_key = routing_key.split('.').last
            results =
              PolicyTaxHouseholds::GenerateAndPublishTaxDocuments.new.call(
                { payload: payload, event_key: routing_key }
              )
            if results.all?(&:success)
              logger.info "Polypress: Cv3FamilyPoliciesSubscriber; acked for #{routing_key}"
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
                    "Polypress: Cv3FamilyPoliciesSubscriber_error;
                  nacked due to:#{errors}; for routing_key: #{routing_key}, payload: #{payload}"
                  )
                end
            end
            ack(delivery_info.delivery_tag)
          rescue StandardError, SystemStackError => e
            logger.error(
              "Polypress: Cv3FamilyPoliciesSubscriber_error: nacked due to backtrace:
              #{e.backtrace}; for routing_key: #{routing_key}, response: #{response}"
            )
            ack(delivery_info.delivery_tag)
          end
        end
      end
    end
  end
end