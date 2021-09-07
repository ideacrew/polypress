# frozen_string_literal: true

module Sections
  # Schema and validation rules for {Sections::Section} domain object
  class SectionItemContract < Contract
    # @!method call(opts)
    # @param [Hash] opts the parameters to validate using this contract
    # @option opts [String] :title required
    # @option opts [String] :description optional
    # @option opts [Polypress::Types::SectionKind] :kind required
    # @option opts [SectionBody] :section_body optional
    # @option opts [Time] :created_at optional
    # @option opts [Time] :updated_at optional
    # @option opts [String] :updated_by optional
    # @option opts [String] :author optional
    # @return [Dry::Monads::Result] :result
    params do
      required(:title).value(:string)
      required(:kind).value(Polypress::Types::SectionKind)
      optional(:description).maybe(:string)
      optional(:section_body).value(SectionBodyContract.params)
      optional(:created_at).maybe(:time)
      optional(:updated_at).maybe(:time)
      optional(:updated_by).maybe(:string)
      optional(:author).maybe(:string)
    end
  end
end
