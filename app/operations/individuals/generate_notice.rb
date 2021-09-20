# frozen_string_literal: true

module Individuals
  # This operation determines eligibilities and publishes documents accordingly
  class GenerateNotice
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    # @param [Templates::TemplateModel] :template_model
    # @param [Hash] :payload
    # @return [Dry::Monads::Result]
    def call(params)
      values = yield validate(params)
      family_entity = yield init_family_entity(values)
      publish_documents(family_entity, params[:template_model])
    end

    def validate(params)
      return Failure("Missing template model") unless params[:template_model].present?
      return Failure("Missing payload") unless params[:payload]

      result = AcaEntities::Contracts::Families::FamilyContract.new.call(params[:payload])
      result.success? ? Success(result.to_h) : Failure(result.errors.to_h)
    end

    def init_family_entity(params)
      family_entity = ::AcaEntities::Families::Family.new(params)
      Success(family_entity)
    rescue StandardError => e
      Failure(e)
    end

    def publish_documents(family_entity, template_model)
      result = MagiMedicaid::PublishDocument.new.call(entity: family_entity, template_model: template_model)
      if result.success?
        Success(result.success)
      else
        Failure("Failed to generate notice for family id: #{family_entity.hbx_id} due to #{result.failure}")
      end
    end
  end
end
