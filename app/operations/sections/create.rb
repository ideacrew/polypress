# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Sections
  # Operation to create Section
  class Create
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    # @param [Sections::Section] :section
    # @param [Array<Dry::Struct>] :entities
    # @return [Dry::Monads::Result] Parsed section as string
    def call(params)
      # serialized_hash = yield serialize_params(dummy_params)
      values = yield validate(params)
      section_entity = yield create_entity(values)
      section = yield create(section_entity)

      Success(section)
    end

    private

    def validate(params)
      params['key'] = params['title'].split(/\s/).map(&:downcase).join('_')
      
      return Success(params)
      # result = Contracts::SectionContract.new.call(params)
      # result.success? ? Success(result.to_h) : Failure(result)
    end

    def create_entity(params)
      section = ::Section.new(params.except(:category, :doc_type, :subject, :key_criteria, :recipient))
      section.save

      return Success(section)
      
      Try() do
        Sections::Section.new(params)
      end.to_result
    end

    def create(entity)
      return Success(entity)
      
      section = ::Section.new(entity.to_h)

      if section.valid? && section.save
        Success(section)
      else
        Failure("Unable to create section for #{entity.title}")
      end
    end
  end
end
