# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module MagiMedicaid
  # Operation to create template
  class PublishUqhpEligibleDocument
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    # send(:include, ::EventSource::Command)

    # @param [Hash] AcaEntities::Families::Family
    # @param [String] :event_key
    # @return [Dry::Monads::Result] Parsed template as string
    def call(params)
      values = yield validate(params)
      family_entity = yield create_entity(values)
      template = yield find_template(params)
      document = yield create_document({ id: template.id, entity: family_entity })
      # result = yield build_event(document)
      Success(document)
    end

    private

    # validating incoming family hash
    def validate(params)
      unless params[:event_key]
        return Failure("Missing event key #{params[:family][:hbx_id]}")
      end

      result =
        AcaEntities::Contracts::Families::FamilyContract.new.call(
          params[:family]
        )
      result.success? ? Success(result.to_h) : Failure(result)
    end

    # create family entity
    def create_entity(params)
      family_entity = AcaEntities::Families::Family.new(params)
      Success(family_entity)
    rescue StandardError => e
      Failure(e)
    end

    def find_template(params)
      template = Template.where(key: params[:event_key]).first
      if template
        Success(template)
      else
        Failure("No template found for the given #{params[:event_key]}")
      end
    end

    def create_document(params)
      Documents::Create.new.call(params)
    end

    # def build_event(values)
    #   event 'magi_medicaid.uqhp_eligible_document_published', attributes: values
    # end
  end
end
