# frozen_string_literal: true

module Events
  # Schema and validation rules for {Events::EventRoute} domain object
  class EventRouteContract < Contract
    # @!method call(opts)
    # @param [Hash] opts the parameters to validate using this contract
    # @option opts [Hash] :event_route_items required
    # @return [Dry::Monads::Result] :result
    params { required(:event_routes).value(:hash) }
  end
end
