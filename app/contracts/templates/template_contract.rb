# frozen_string_literal: true

module Templates
  # Schema and validation rules for {Templates::Template} domain object
  class TemplateContract < Contract
    # @!method call(opts)
    # @param [Hash] opts the parameters to validate using this contract
    # @option opts [String] :_id optional
    # @option opts [String] :key required
    # @option opts [String] :title required
    # @option opts [AcaEntities::Types::MarketPlaceKinds] :marketplace required
    # @option opts [String] :description optional
    # @option opts [Array<String>] :events required
    # @option opts [String] :locale optional
    # @option opts [Bodies::BodyContract] :body optional
    # @option opts [String] :print_code optional
    # @option opts [Time] :created_at optional
    # @option opts [Time] :updated_at optional
    # @option opts [String] :updated_by optional
    # @option opts [String] :author optional
    # @return [Dry::Monads::Result] :result
    params do
      optional(:_id).filled(:string)
      optional(:key).maybe(:string)
      required(:title).filled(:string)
      required(:marketplace).value(AcaEntities::Types::MarketPlaceKinds)
      optional(:description).maybe(:string)
      optional(:locale).maybe(:string)
      optional(:content_type).maybe(:string)
      optional(:body).value(Bodies::BodyContract.params)
      optional(:print_code).maybe(:string)
      optional(:publisher).maybe(EventRoutes::EventRouteContract.params)
      optional(:subscriber).maybe(EventRoutes::EventRouteContract.params)
      optional(:author).maybe(:string)
      optional(:recipient).maybe(:string)
      optional(:updated_by).maybe(:string)
      optional(:published_at).maybe(:time)
      optional(:created_at).maybe(:time)
      optional(:updated_at).maybe(:time)
      optional(:paper_communication_override).maybe(:bool)
    end
  end
end
