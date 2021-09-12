# frozen_string_literal: true

module Events
  # Schema and validation rules for {Events::EventRouteItem} domain object
  class EventRouteItemContract < Contract
    # @!method call(opts)
    # @param [Hash] opts the parameters to validate using this contract
    # @option opts [Hash] :attributes required
    # @option opts [String] :criteria optional
    # @option opts [String] :template_key required
    # @return [Dry::Monads::Result] :result
    params do
      required(:template_key).value(:string)
      optional(:attributes).value(:hash)
      optional(:criteria).value(:string)
    end

    rule(:criteria) do
      # Validate presence of attributes when criteria is present
    end
  end
end
