# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Sections
  # Search by key to find a {Sections::Section} in the database
  class Find
    include Dry::Monads[:result, :do, :try]

    # @param [Hash] opts the parameters used to search for the SectionItem
    # @option opts [Hash] :scope_name required
    # @option opts [Hash] :options optional
    # @return [Dry::Monad] result
    def call(params)
      values = yield validate(params)
      templates = yield search(values)

      Success(templates)
    end

    private

    def validate(params)
      if params.keys.include? :scope_name
        Success(params)
      else
        Failure('params must include :scope_name')
      end
    end

    def search(values)
      Try() do
        scope_name = values[:scope_name]
        if values[:options].present?
          Sections::SectionModel.send(scope_name, values[:options])
        else
          Sections::SectionModel.send(scope_name)
        end
      end.bind do |result|
        return Failure(result) unless result.is_a?(Mongoid::Criteria)
        Success(result.to_a)
      end
    end
  end
end
