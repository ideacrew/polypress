# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Accounts
  # Add a new Account
  # a {Sections::SectionItem}
  class ResetPassword
    include Dry::Monads[:result, :do, :try]

    # @param [Hash] opts the parameters to render a SectionItem
    # @option opts [String] :account_id required
    # @option opts [Hash] :credentials required
    # @option opts [Hash] :access_token optional
    # @return [Dry::Monad] result
    # @return [Dry::Monad::Failure(Array<Liquid::UndefinedVariable>)] if parsing errors occur
    def call(params)
      values = yield validate(params)
      result = yield reset_password(values)

      Success(result)
    end

    private

    def validate(params)
      # Account has email
    end

    def reset_password(values)
      Try() do
        Keycloak::Internal.forgot_password(values[:email], values[:root_path])
      end.to_result
    end
  end
end
