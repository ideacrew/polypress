# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Accounts
  # Create a new Keycloak Account
  # a {Sections::SectionItem}
  class Create
    include Dry::Monads[:result, :do, :try]

    # @param [Hash] opts the parameters to create a {AcaEntities::Accounts::Account}
    # @option opts [String] :username optional
    # @option opts [String] :password optional
    # @option opts [String] :email optional
    # @option opts [String] :first_name optional
    # @option opts [String] :last_name optional
    # @return [Dry::Monad] result
    def call(params)
      values = yield validate(params)
      new_account = yield create(values.to_h)

      Success(new_account)
    end

    private

    def validate(params)
      AcaEntities::Accounts::Contracts::AccountContract.new.call(params)
    end

    def create(values)
      Try() do
        after_insert =
          lambda do |user, new_user|
            return { 'user' => user, 'new_user' => new_user }
          end

        Keycloak::Internal.create_simple_user(
          values[:username] || values[:email],
          values[:password],
          values[:email],
          values[:first_name],
          values[:last_name],
          [],
          ['Public'],
          after_insert
        )
      end.to_result.bind do |response|
        response['new_user'] ? Success(response) : Failure(response)
      end
    end
  end
end
