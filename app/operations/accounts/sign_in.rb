Keycloak::Client.get_token params[:email], params[:password]

# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Accounts
  # Add a new Account
  # a {Sections::SectionItem}
  class ResetPassword
    include Dry::Monads[:result, :do, :try]

    # @param [Hash] opts the parameters to render a SectionItem
    # @option opts [Hash] :template required
    # @option opts [Hash] :attributes optional
    # @return [Dry::Monad] result
    # @return [Dry::Monad::Failure(Array<Liquid::UndefinedVariable>)] if parsing errors occur
    def call(params)
      values = yield validate(params)
      tokens = yield sign_in(values)

      Success(tokens)
    end

    private

    def validate(params)
      Accounts::AccountContract.new.call(params)
    end

    def create(values)
      Keycloak::Internal.create_simple_user(
        params[:email],
        params[:password],
        params[:email],
        params[:first_name],
        params[:last_name],
        [],
        ['Public'],
        after_insert
      )
    end
  end
end
