# frozen_string_literal: true

require 'rails_helper'
require "#{Rails.root}/spec/shared_examples/eligibilities/application_response"
require "#{Rails.root}/spec/shared_examples/enrollments/family_response"

RSpec.describe MagiMedicaid::GenerateAndPublishEligibilityDocuments do
  describe 'with valid arguments' do
    include_context 'application response from medicaid gateway'
    include_context 'family response from enroll'

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

    let(:payload_hash) { application_hash }

    subject do
      described_class.new.call(
        payload: payload_hash,
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

    context 'when family has is passed in' do
      before do
        Events::Documents::DocumentCreated
          .any_instance
          .stub(:publish)
          .and_return(true)
      end
      let(:payload_hash) { family_hash }

      it 'should return success' do
        expect(subject[0].success?).to be_truthy
      end

      context 'when generation fails' do
        let(:body) { '<p>Uqhp Eligible Document for {{ hbx_id }} {{ unknown_key }}</p>' }

        it 'should return failure' do
          expect(subject[0].success?).to be_falsey
        end

        it 'should log error' do
          expect(subject[0].failure).to match(/Failed to generate #{event_key} for family id/)
        end
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
      shared_examples 'eligibility determination' do |event_key, expected_result|
        let(:eligibilities) do
          MagiMedicaid::GenerateAndPublishEligibilityDocuments.new
                                                              .determine_eligibilities(application_entity, event_key)
        end

        expected_result = expected_result.present? ? [expected_result] : []
        it "should return #{expected_result}" do
          expect(eligibilities.success).to eq expected_result
        end
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

        let(:application_entity) { ::AcaEntities::MagiMedicaid::Application.new(modified_application_hash) }
        it_behaves_like 'eligibility determination',
                        'magi_medicaid.mitc.eligibilities.determined_mixed_determination',
                        nil
      end

      context 'when event key is determined_mixed_determination' do
        it_behaves_like 'eligibility determination',
                        'magi_medicaid.mitc.eligibilities.determined_mixed_determination',
                        'magi_medicaid.mitc.eligibilities.determined_aptc_eligible'
      end

      context 'when event key is determined_medicaid_chip_eligible' do
        it_behaves_like 'eligibility determination',
                        'magi_medicaid.applications.aptc_csr_credits.renewals.determined_medicaid_chip_eligible',
                        'magi_medicaid.applications.aptc_csr_credits.renewals.determined_magi_medicaid_eligible'
        it_behaves_like 'eligibility determination',
                        'enroll.applications.aptc_csr_credits.renewals.notice.determined_medicaid_chip_eligible',
                        'enroll.applications.aptc_csr_credits.renewals.notice.determined_magi_medicaid_eligible'
      end

      context 'when event key is determined_aptc_eligible' do
        it_behaves_like 'eligibility determination',
                        'magi_medicaid.applications.aptc_csr_credits.renewals.determined_aptc_eligible',
                        'magi_medicaid.applications.aptc_csr_credits.renewals.determined_aptc_eligible'
        it_behaves_like 'eligibility determination',
                        'enroll.applications.aptc_csr_credits.renewals.notice.determined_aptc_eligible',
                        'enroll.applications.aptc_csr_credits.renewals.notice.determined_aptc_eligible'
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