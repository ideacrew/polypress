# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Sections
  # Search by key to find a {Sections::SectionItem} in the database
  class FindSectionItem
    include Dry::Monads[:result, :do, :try]

    # @param [Hash] opts the parameters used to search for the SectionItem
    # @option opts [Hash] :key required
    # @return [Dry::Monad] result
    def call(params)
      values = yield validate(params)
      section_item = yield search(values)

      Success(section_item)
    end

    private

    def validate(params)
      Sections::SectionContract.new.call(params[:section_item])
    end

    def search(values)
      section_item = Section.where(key: values[:key].to_s)
      if section_item.to_a.empty?
        Failure("key not found: #{values[:key]}")
      else
        Success(section_item.first)
      end
    end
  end
end
