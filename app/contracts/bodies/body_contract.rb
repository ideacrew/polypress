# frozen_string_literal: true

module Bodies
  # Schema and validation rules for {Bodies::Body} domain object
  class BodyContract < Contract
    # @!method call(opts)
    # @param [Hash] opts the parameters to validate using this contract
    # @option opts [String] :markup optional
    # @option opts [Polypress::Types::MimeType] :content_type optional
    # @option opts [Hash] :schema optional
    # @option opts [Hash] :settings optional
    # @return [Dry::Monads::Result] :result
    params do
      # required(:content_type).maybe(Polypress::Types::MimeType)
      optional(:encoding_type).maybe(:string)
      optional(:content_type).maybe(:string)
      optional(:markup).maybe(:string)
    end
  end
end
