# frozen_string_literal: true

module Subscribers
  module MagiMedicaid
    # Subscribes to the eligibility determination events
    class EligibilityDeterminationsSubscriber
      include EventSource::Subscriber

      subscription 'magi_medicaid.eligibility_determinations'

      def on_determined_uqhp_eligible(params)
        puts "EA------------->>>>>person subscriber reached with #{params.inspect}"

        # @param [Hash] AcaEntities::Families::Family
        # @param [String] :event_key
        # @return [Dry::Monads::Result] Parsed template as string
        MagiMedicaid::PublishUqhpEligibleDocument.call(params)
      end

      def on_determined_aqhp_eligible(params)
        puts "EA------------->>>>>person subscriber reached with #{params.inspect}"

        MagiMedicaid::PublishAqhpEligibleDocument.call(params)
      end

      def on_determined_magi_medicaid_eligible(params)
        puts "EA------------->>>>>person subscriber reached with #{params.inspect}"

        MagiMedicaid::PublishMedicaidEligibleDocument.call(params)
      end

      def on_determined_totally_ineligible(params)
        puts "EA------------->>>>>person subscriber reached with #{params.inspect}"

        MagiMedicaid::PublishTotallyIneligibleDocument.call(params)
      end
    end
  end
end