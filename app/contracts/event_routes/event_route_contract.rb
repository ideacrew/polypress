# frozen_string_literal: true

module EventRoutes
  # Schema and validation rules for {Events::EventRoute} domain object
  class EventRouteContract < Contract
    # @!method call(opts)
    # @param [Hash] opts the parameters to validate using this contract
    # @option opts [String] :event_name required
    # @option opts [Hash] :attributes required
    # @option opts [String] :filter_criteria optional
    # @return [Dry::Monads::Result] :result
    params do
      required(:event_name).value(:string)
      optional(:event_attributes).maybe(:hash)
      optional(:filter_criteria).maybe(:string)
    end
  end
end
