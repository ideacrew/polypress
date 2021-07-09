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
      family_entity = yield init_family_entity(values)
      publish_documents(family_entity, params[:event_key])
    end

    def validate(params)
      return Failure("Missing event key for given payload: #{params[:family_hash][:hbx_id]}") unless params[:event_key]

      result = AcaEntities::Contracts::Families::FamilyContract.new.call(params[:family_hash])
      result.success? ? Success(result.to_h) : Failure(result)
    end

    def init_family_entity(params)
      family_entity = ::AcaEntities::Families::Family.new(params)
      Success(family_entity)
    rescue StandardError => e
      Failure(e)
    end

    def publish_documents(family_entity, event_key)
      result = MagiMedicaid::PublishDocument.new.call(entity: family_entity, event_key: event_key)
      if result.success?
        Success(result.success)
      else
        Failure("Failed to generate #{event_key} for family id: #{family_entity.hbx_id} due to #{result.failure}")
      end
    end
  end
end
