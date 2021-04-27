# frozen_string_literal: true

module Contracts
  # Schema and validation rules for {Tags::Tag} domain object
  class TemplateContract < Dry::Validation::Contract
    # @!method call(opts)
    # @param [Hash] opts the parameters to validate using this contract
    # @option opts [String] :name required
    # @option opts [String] :description optional
    # @return [Dry::Monads::Result] :result
    params do
      required(:key).filled(:symbol)
      optional(:title).maybe(:string)
      optional(:description).maybe(:string)
      optional(:content_type).maybe(:string)
      optional(:recipient).maybe(:string)
      optional(:cc_recipients).maybe(:array)
      optional(:locale).maybe(:string)
      optional(:entities).maybe(:array)
      optional(:body).maybe(:string)
      optional(:subject).maybe(:string)
      optional(:category).maybe(:string)
      optional(:tags).maybe(:string)
    end
  end
end