# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Accounts
  # Change the password for a {AcaEntities::Accounts::Account}
  class ForgotPassword
    include Dry::Monads[:result, :do, :try]

    # @param [Hash] opts the parameters to change an Account password
    # @option opts [String] :username required
    # @return [Dry::Monad] result
    def call(params)
      values = yield validate(params)
      result = yield reset_password(values.to_h)

      Success(result)
    end

    private

    def validate(params)
      if params.keys.include? :username
        Success(params)
      else
        Failure('params must include :username')
      end
    end

    def reset_password(values)
      Try() do
        Keycloak.proc_cookie_token =
          lambda { cookies.permanent[:keycloak_token] }

        Keycloak::Internal.forgot_password(values[:username])
        binding.pry
      end.to_result.bind { |response| Success(response) }
    end
  end
end
