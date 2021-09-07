# frozen_string_literal: true

require 'mime/types'

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
    # @option opts [Array<String>] :order required
    # @option opts [Array<String>] :categories optional
    # @option opts [Array<String>] :tags optional
    # @option opts [Time] :created_at optional
    # @option opts [Time] :updated_at optional
    # @option opts [String] :updated_by optional
    # @option opts [String] :author optional
    # @return [Dry::Monads::Result] :result
    params do
      required(:key).filled(:string)
      required(:title).filled(:string)
      optional(:description).maybe(:string)
      required(:events).array(:string)
      required(:sections).value(Sections::Sections.params)
      optional(:section_order).array(:string)
      optional(:locale).array(:string)
      optional(:categories).array(:string)
      required(:tags).array(:string)
      optional(:created_at).maybe(:time)
      optional(:updated_at).maybe(:time)
      optional(:updated_by).maybe(:string)
      optional(:author).maybe(:string)
    end
  end
end
