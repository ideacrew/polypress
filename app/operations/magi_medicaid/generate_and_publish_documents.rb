# frozen_string_literal: true

module MagiMedicaid
  # This operation determines eligibilities and publishes documents accordingly
  class GenerateAndPublishDocuments
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    # @param [Hash] AcaEntities::MagiMedicaid::Application
    # @param [String] :event_key
    # @return [Dry::Monads::Result]
    def call(params)
      values = yield validate(params)
      application_entity = yield init_application_entity(values)
      eligibilities = yield determine_eligibilities(application_entity, params[:event_key])
      publish_documents(application_entity, eligibilities)
    end

    def validate(params)
      return Failure("Missing event key for resource_id: #{params[:application][:family_reference][:hbx_id]}") unless params[:event_key]

      result =
        ::AcaEntities::MagiMedicaid::Contracts::ApplicationContract.new.call(
          params[:application]
        )
      result.success? ? Success(result.to_h) : Failure(result)
    end

    def init_application_entity(params)
      application_entity = ::AcaEntities::MagiMedicaid::Application.new(params)
      Success(application_entity)
    rescue StandardError => e
      Failure(e)
    end

    def determine_eligibilities(application_entity, event_key)
      return Success([event_key]) unless event_key.to_s == 'determined_mixed_determination'

      peds = application_entity.tax_households.flat_map(&:tax_household_members).map(&:product_eligibility_determination)
      event_names =
        peds.inject([]) do |e_names, ped|
          e_name =
            if ped.is_ia_eligible
              'determined_aptc_eligible'
            elsif ped.is_medicaid_chip_eligible || ped.is_magi_medicaid
              'determined_magi_medicaid_eligible'
            elsif ped.is_totally_ineligible
              'determined_totally_ineligible'
            elsif ped.is_uqhp_eligible
              'determined_uqhp_eligible'
            end

          e_names << e_name
        end
      Success(event_names.uniq.compact)
    end

    def publish_documents(application_entity, event_keys)
      event_keys.collect do |event_key|
        result = MagiMedicaid::PublishUqhpEligibleDocument.new.call(application_entity: application_entity, event_key: event_key)
        if result.success?
          Success(result.success)
        else
          Failure("Failed to generate #{event_key} for family id: #{application_entity.family_reference.hbx_id} due to #{result.failure}")
        end
      end
    end
  end
end
