# frozen_string_literal: true

module PolicyTaxHouseholds
  # This operation determines eligibilities and publishes documents accordingly
  class GenerateAndPublishTaxDocuments
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    # @param [Hash] AcaEntities::MagiMedicaid::Application to hash
    # @param [String] :event_key
    # @return [Dry::Monads::Result]
    def call(_params)
      Success(true)
    end
  end
end
