# frozen_string_literal: true

require 'rails_helper'
require "#{Rails.root}/spec/shared_examples/eligibilities/application_response"

RSpec.describe MagiMedicaid::GenerateAndPublishEligibilityDocuments do
  describe 'with valid arguments' do
    include_context 'application response from medicaid gateway'

    let(:title) { 'Uqhp Document' }
    let(:event_key) { 'magi_medicaid.mitc.eligibilities.determined_uqhp_eligible' }
    let(:body) { '<p>Uqhp Eligible Document for {{ hbx_id }}</p>' }

    let!(:template) do
      FactoryBot.create(
        :template,
        key: event_key,
        body: {
          markup: body
        },
        title: title,
        marketplace: 'aca_individual',
        recipient: 'AcaEntities::Families::Family',
        content_type: 'application/pdf',
        description: 'Uqhp Description',
        subscriber: EventRoutes::EventRouteModel.new(event_name: event_key)
      )
    end
    let(:application_entity) do
      ::AcaEntities::MagiMedicaid::Application.new(application_hash)
    end

    subject do
      described_class.new.call(
        payload: application_hash,
        event_key: event_key
      )
    end

    context 'when payload has all the required params' do
      before do
        Events::Documents::DocumentCreated
          .any_instance
          .stub(:publish)
          .and_return(true)
      end

      it 'should return success' do
        expect(subject[0].success?).to be_truthy
      end
    end

    context 'when event key is missing' do
      let(:event_key) { nil }

      let(:error) do
        "Missing event key"
      end

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure).to eq error
      end
    end

    context '#determine_eligibilities' do
      let(:event_key) { 'magi_medicaid.mitc.eligibilities.determined_mixed_determination' }
      let(:eligibilities) do
        MagiMedicaid::GenerateAndPublishEligibilityDocuments.new
                                                            .determine_eligibilities(application_entity, event_key)
      end

      it 'should return eligibilities' do
        expect(eligibilities.success).to eq ['magi_medicaid.mitc.eligibilities.determined_aptc_eligible']
      end

      context 'when there is no eligibility' do
        let!(:modified_application_hash) do
          application_hash[:tax_households][0][:tax_household_members][0][:product_eligibility_determination].merge!(
            is_ia_eligible: false,
            is_medicaid_chip_eligible: false,
            is_magi_medicaid: false,
            is_totally_ineligible: false,
            is_uqhp_eligible: false
          )
          application_hash
        end

        let(:entity) { ::AcaEntities::MagiMedicaid::Application.new(modified_application_hash) }
        let(:eligibilities) do
          MagiMedicaid::GenerateAndPublishEligibilityDocuments.new
                                                              .determine_eligibilities(application_entity, event_key)
        end

        it 'should return nil' do
          expect(eligibilities.success).to eq []
        end
      end
    end

    context '#publish_documents' do
      let(:publish_document) do
        MagiMedicaid::GenerateAndPublishEligibilityDocuments.new
                                                            .publish_documents(application_entity, [])
      end

      context 'when event keys are missing' do
        let(:error) { "Failed to generate notices for family id: #{application_entity.family_reference.hbx_id} due to missing events" }

        it 'should return failure' do
          expect(publish_document[0].failure?).to be_truthy
        end

        it 'should return error' do
          expect(publish_document[0].failure).to eq error
        end
      end
    end

    context 'when input application hash is invalid' do
      let(:error) do
        '[#<Dry::Schema::Message text="is missing" path=[:family_reference, :hbx_id] predicate=:key? input={}>]'
      end

      before { application_hash[:family_reference].delete(:hbx_id) }

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure.errors.messages.to_s).to eq error
      end
    end
  end
end
