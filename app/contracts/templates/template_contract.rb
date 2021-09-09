# frozen_string_literal: true

module Templates
  # Schema and validation rules for {Templates::Template} domain object
  class TemplateContract < Contract
    # @!method call(opts)
    # @param [Hash] opts the parameters to validate using this contract
    # @option opts [String] :key required
    # @option opts [String] :title required
    # @option opts [String] :description optional
    # @option opts [Array<String>] :events required
    # @option opts [Sections::Section] :sections required
    # @option opts [String] :locale optional
    # @option opts [Time] :created_at optional
    # @option opts [Time] :updated_at optional
    # @option opts [String] :updated_by optional
    # @option opts [String] :author optional
    # @return [Dry::Monads::Result] :result
    params do
      optional(:_id).filled(:string)
      required(:key).filled(:string)
      required(:marketplace).maybe(AcaEntities::Types::MarketPlaceKinds)
      required(:title).filled(:string)
      optional(:description).maybe(:string)
      optional(:locale).maybe(:string)
      optional(:content_type).maybe(:string)
      optional(:print_code).maybe(:string)
      optional(:markup_section).maybe(:string)
      optional(:author).maybe(:string)
      optional(:updated_by).maybe(:string)
      optional(:created_at).maybe(:time)
      optional(:updated_at).maybe(:time)
    end
  end
end
