# frozen_string_literal: true

module Tags
  # Schema and validation rules for {Tags::Tag} domain object
  class TagContract < Contract
    # @!method call(opts)
    # @param [Hash] opts the parameters to validate using this contract
    # @option opts [String] :namespace optional
    # @option opts [String] :key required
    # @option opts [String] :value required
    # @option opts [String] :description optional
    # @return [Dry::Monads::Result] :result
    params do
      required(:full_key).value(:string)
      optional(:namespace).maybe(:string)
      required(:key).filled(:symbol)
      required(:value).filled(:any)
      optional(:description).maybe(:string)

      before(:value_coercer) do |result|
        parms = result.to_h
        if parms[:key].present?
          if parms[:namespace].present?
            result.to_h.merge!(
              { full_key: [parms[:namespace], parms[:key].to_s].join('.') }
            )
          else
            result.to_h.merge!({ full_key: parms[:key].to_s })
          end
        end
      end
    end
  end
end
