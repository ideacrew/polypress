# frozen_string_literal: true

module Sections
  # Schema and validation rules for {Sections::Sections} domain object
  class SectionContract < Contract
    # @!method call(opts)
    # @param [Hash] opts the parameters to validate using this contract
    # @option opts [Hash] :sections required
    # @return [Dry::Monads::Result] :result
    params do
      optional(:_id).value(:string)
      required(:key).value(:string)
      optional(:section_item).hash do
        required(:title).value(:string)
        required(:kind).value(Polypress::Types::SectionKind)
        optional(:description).maybe(:string)

        optional(:body).value(Bodies::BodyContract.params)

        optional(:updated_by).maybe(:string)
        optional(:author).maybe(:string)
        optional(:created_at).maybe(:time)
        optional(:updated_at).maybe(:time)
      end
    end
  end
end
