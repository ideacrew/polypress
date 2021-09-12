# frozen_string_literal: true

require 'dry/validation'

# Configuration values and shared rules and macros for domain model validation contracts
class Contract < Dry::Validation::Contract
  # config.messages.load_paths - an array of files paths that are used to load messages
  # config.messages.default_locale = :en
  # config.messages.backend = :i18n
  # config.messages.top_namespace = :dry_validation
  # config.messages.namespace :request
  # Process validation contracts in a standard manner
  # @param evaluator [Dry::Validation::Contract::Evaluator]
  # rule(:tags).each do |key, value|
  #   if key? && value
  #     result = Metadata::TagContract.new.call(value)
  #     key.failure(text: "invalid tag", error: result.errors.to_h) if result&.failure?
  #   end
  # end
  # rule(:owner, :created_by) do
  #   if key? && value
  #     result = AccountContract.new.call(value)
  #     key.failure(text: "invalid account", error: result.errors.to_h) if result&.failure?
  #   end
  # end
end
