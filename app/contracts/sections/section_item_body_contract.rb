# frozen_string_literal: true

module Sections
  # Schema and validation rules for {Sections::SectionItemBody} domain object
  class SectionItemBodyContract < Contract
    # @!method call(opts)
    # @param [Hash] opts the parameters to validate using this contract
    # @option opts [String] :markup optional
    # @option opts [Polypress::Types::MimeType] :content_type optional
    # @option opts [Hash] :schema optional
    # @option opts [Hash] :settings optional
    # @return [Dry::Monads::Result] :result
    params do
      # required(:content_type).maybe(Polypress::Types::MimeType)
      optional(:content_type).maybe(:string)
      optional(:markup).value(:string)
      # optional(:schema).value(:hash)
      # optional(:settings).value(:hash)
    end
  end
end
