# frozen_string_literal: true

require 'rails_helper'
require "#{Rails.root}/spec/shared_examples/eligibilities/application_response"

RSpec.describe MagiMedicaid::GenerateAndPublishEligibilityDocuments do
  describe 'with valid arguments' do
    include_context 'application response from medicaid gateway'

    let(:title) { 'Uqhp Document' }
    let(:event_key) { 'determined_uqhp_eligible' }
    let(:body) { '<p>Uqhp Eligible Document for {{ hbx_id }}</p>' }
    let(:template_subject) { 'Uqhp Subject' }

    let!(:template) do
      FactoryBot.create(
        :template,
        key: event_key,
        body: body,
        title: title,
        subject: template_subject,
        category: 'aca_individual',
        recipient: 'AcaEntities::Families::Family',
        content_type: 'application/pdf',
        description: 'Uqhp Descriptoin'
      )
    end
    let(:application_entity) { ::AcaEntities::MagiMedicaid::Application.new(application_hash) }

    subject do
      described_class.new.call(application: application_hash, event_key: event_key)
    end

    context "when payload has all the required params" do
      it 'should return success' do
        expect(subject[0].success?).to be_truthy
      end
    end

    context "when event key is missing" do
      let(:event_key) { nil }

      let(:error) { "Missing event key for resource_id: #{application_hash[:family_reference][:hbx_id]}" }

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure).to eq error
      end
    end

    context "#determine_eligibilities" do
      let(:event_key) { 'determined_mixed_determination' }
      let(:eligibilities) { MagiMedicaid::GenerateAndPublishEligibilityDocuments.new.determine_eligibilities(application_entity, event_key) }

      it 'should eligibilities' do
        expect(eligibilities.success).to eq ["determined_aptc_eligible"]
      end
    end

    context "when input application hash is invalid" do
      let(:error) { '[#<Dry::Schema::Message text="is missing" path=[:family_reference, :hbx_id] predicate=:key? input={}>]' }

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
