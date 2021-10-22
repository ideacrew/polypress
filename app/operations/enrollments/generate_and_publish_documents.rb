# frozen_string_literal: true

module Enrollments
  # This operation publishes enrollment documents
  class GenerateAndPublishDocuments
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    # @param [Hash] AcaEntities::Families::Family
    # @param [String] :event_key
    # @return [Dry::Monads::Result]
    def call(params)
      values = yield validate(params)
      template_model = yield template_model(params)
      family_entity = yield init_family_entity(values)
      publish_documents(family_entity, template_model)
    end

    def validate(params)
      return Failure("Missing event key for given payload: #{params[:family_hash][:hbx_id]}") unless params[:event_key]

      result = AcaEntities::Contracts::Families::FamilyContract.new.call(params[:family_hash])
      result.success? ? Success(result.to_h) : Failure(result.errors.to_h)
    end

    def template_model(params)
      template_model = Templates::TemplateModel.where(:'subscriber.event_name' => params[:event_key]).first

      if template_model.present?
        Success(template_model)
      else
        Failure("Unable to find template model")
      end
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
        Failure("Failed to generate #{template_model.subscriber&.event_name} for family id: #{family_entity.hbx_id} due to #{result.failure}")
      end
    end
  end
end
