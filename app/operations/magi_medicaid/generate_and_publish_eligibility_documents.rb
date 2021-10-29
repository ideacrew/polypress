# frozen_string_literal: true

module MagiMedicaid
  # This operation determines eligibilities and publishes documents accordingly
  class GenerateAndPublishEligibilityDocuments
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    # @param [Hash] AcaEntities::MagiMedicaid::Application to hash
    # @param [String] :event_key
    # @return [Dry::Monads::Result]
    def call(params)
      values = yield validate(params)
      entity = yield init_entity(values)
      eligibilities = yield determine_eligibilities(entity, params[:event_key])
      publish_documents(entity, eligibilities)
    end

    def validate(params)
      return Failure("Missing event key") unless params[:event_key]
      return Failure("Missing payload") unless params[:payload]

      result =
        if params[:payload][:applicants].present?
          ::AcaEntities::MagiMedicaid::Contracts::ApplicationContract.new.call(params[:payload])
        else
          AcaEntities::Contracts::Families::FamilyContract.new.call(params[:payload])
        end
      result.success? ? Success(result.to_h) : Failure(result)
    end

    def init_entity(params)
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

    def determine_eligibilities(entity, event_key)
      unless event_key.to_s.include?('determined_mixed_determination') || event_key.to_s.include?('mixed_determination_on_reverification')
        return Success([event_key])
      end

      peds = entity.tax_households.flat_map(&:tax_household_members).map(&:product_eligibility_determination)
      event_names =
        peds.inject([]) do |e_names, ped|
          e_name =
            if ped.is_ia_eligible
              aqhp_event(event_key)
            elsif ped.is_medicaid_chip_eligible || ped.is_magi_medicaid
              medicaid_event(event_key)
            elsif ped.is_totally_ineligible
              ineligible_event(event_key)
            elsif ped.is_uqhp_eligible
              uqhp_event(event_key)
            end

          e_names << event_name(event_key, e_name)
        end
      Success(event_names.compact.uniq)
    end

    def source_enroll?(event_key)
      event_key.include?('enroll')
    end

    def aqhp_event(event_key)
      source_enroll?(event_key) ? 'aqhp_eligible_on_reverification' : 'determined_aptc_eligible'
    end

    def medicaid_event(event_key)
      source_enroll?(event_key) ? 'medicaid_eligible_on_reverification' : 'determined_magi_medicaid_eligible'
    end

    def ineligible_event(event_key)
      source_enroll?(event_key) ? 'totally_ineligible_on_reverification' : 'determined_totally_ineligible'
    end

    def uqhp_event(event_key)
      source_enroll?(event_key) ? 'uqhp_eligible_on_reverification' : 'determined_uqhp_eligible'
    end

    def event_name(event_key, eligibility)
      return unless eligibility.present?

      event_key_array = event_key.split('.')
      event_key_array.pop
      event_key_array.push(eligibility).join('.')
    end

    def template_model(event_key)
      Templates::TemplateModel.where(:'subscriber.event_name' => event_key).first
    end

    def publish_documents(application_entity, event_keys)
      unless event_keys.present?
        return [Failure("Failed to generate notices for family id: #{application_entity.family_reference.hbx_id} due to missing events")]
      end

      event_keys.collect do |event_key|
        result = MagiMedicaid::PublishDocument.new.call(entity: application_entity, template_model: template_model(event_key))
        if result.success?
          Success(result.success)
        else
          Failure("Failed to generate #{event_key} for family id: #{application_entity.family_reference.hbx_id} due to #{result.failure}")
        end
      end
    end
  end
end
