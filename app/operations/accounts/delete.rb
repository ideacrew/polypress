# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Accounts
  # Create a new Keycloak Account
  # a {Sections::SectionItem}
  class Delete
    include Dry::Monads[:result, :do, :try]

    # @param [Hash] opts the parameters to create a {AcaEntities::Accounts::Account}
    # @option opts [String] :account_id required
    # @return [Dry::Monad] result
    def call(params)
      values = yield validate(params)
      result = yield delete(values.to_h)

      Success(result)
    end
    !!!private

    def validate(params)
      if params.keys.include? :id
        Success(params)
      else
        Failure('params must include :id')
      end
    end

    def delete(values)
      Try() { Keycloak::Admin.delete_user(values[:id]) }.to_result
        .bind { |response| Success(response) }
    end
  end
end
