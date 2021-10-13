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
      entity = yield init_entity_entity(values)
      publish_documents(entity, params[:template_model])
    end

    def validate(params)
      return Failure("Missing template model") unless params[:template_model].present?
      return Failure("Missing payload") unless params[:payload]

      result =
        if params[:payload][:applicants].present?
          ::AcaEntities::MagiMedicaid::Contracts::ApplicationContract.new.call(params[:payload])
        else
          AcaEntities::Contracts::Families::FamilyContract.new.call(params[:payload])
        end
      result.success? ? Success(result.to_h) : Failure(result.errors.to_h)
    end

    def init_entity_entity(params)
      entity =
        if params[:applicants].present?
          ::AcaEntities::MagiMedicaid::Application.new(params)
        else
          ::AcaEntities::Families::Family.new(params)
        end
      Success(entity)
    rescue StandardError => e
      Failure(e)
    end

    def publish_documents(entity, template_model)
      result = MagiMedicaid::PublishDocument.new.call(entity: entity, template_model: template_model)
      if result.success?
        Success(result.success)
      else
        Failure("Failed to generate notice for family id: #{entity.hbx_id} due to #{result.failure}")
      end
    end
  end
end
