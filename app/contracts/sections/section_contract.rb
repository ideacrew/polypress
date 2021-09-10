# frozen_string_literal: true

module Sections
  # Schema and validation rules for {Sections::Sections} domain object
  class SectionContract < Contract
    # @!method call(opts)
    # @param [Hash] opts the parameters to validate using this contract
    # @option opts [String] :_id optional
    # @option opts [String] :key required
    # @option opts [String] :title required
    # @option opts [String] :description optional
    # @option opts [String] :locale optional
    # @option opts [Bodies::BodyContract] :body optional
    # @option opts [Time] :created_at optional
    # @option opts [Time] :updated_at optional
    # @option opts [String] :updated_by optional
    # @option opts [String] :author optional
    # @return [Dry::Monads::Result] :result
    params do
      optional(:_id).value(:string)
      required(:key).value(:string)
      optional(:section_item).hash do
        required(:title).value(:string)
        optional(:description).maybe(:string)
        optional(:locale).maybe(:string)
        optional(:body).value(Bodies::BodyContract.params)
        optional(:author).maybe(:string)
        optional(:updated_by).maybe(:string)
        optional(:created_at).maybe(:time)
        optional(:updated_at).maybe(:time)
      end
    end
  end
end
