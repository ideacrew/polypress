# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Templates
  # Operation to create template
  class Create
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    # @param [Templates::Template] :template
    # @param [Array<Dry::Struct>] :entities
    # @return [Dry::Monads::Result] Parsed template as string
    def call(params)
      # serialized_hash = yield serialize_params(dummy_params)
      values = yield validate(params)
      template_entity = yield create_entity(values)
      template = yield create(template_entity)

      Success(template)
    end

    private

    def validate(params)
      result = Contracts::TemplateContract.new.call(params)
      result.success? ? Success(result.to_h) : Failure(result)
    end

    def create_entity(params)
      Try() do
        Entities::Templates::Template.new(params)
      end.to_result
    end

    def create(entity)
      template = Template.new(entity.to_h)
      if template.valid? && template.save
        Success(template)
      else
        Failure("Unable to create template for #{entity.title}")
      end
    end
  end
end
