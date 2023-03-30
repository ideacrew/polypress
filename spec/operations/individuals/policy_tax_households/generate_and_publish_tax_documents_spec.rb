# frozen_string_literal: true

require 'rails_helper'
require "#{Rails.root}/spec/shared_examples/enrollments/family_response"

RSpec.describe Individuals::PolicyTaxHouseholds::GenerateAndPublishTaxDocuments do
  describe 'with valid arguments' do
    include_context 'family response from enroll'

    let(:title) { '1095 A Notice' }
    let(:event_key) { 'edi_gateway.families.tax_form1095a.initial' }
    let(:body) { '<p>1095A tax notice {{ hbx_id }}</p>' }
    let(:template_subject) { '1095 A Notice Subject' }

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
        description: '1095 A Description',
        subscriber: EventRoutes::EventRouteModel.new(event_name: event_key)
      )
    end

    let(:application_entity) do
      ::AcaEntities::Families::Family.new(family_hash)
    end

    subject do
      described_class.new.call(family_hash: family_hash, event_key: event_key)
    end

    context 'when payload has all the required params' do
      before do
        Events::Documents::DocumentCreated
          .any_instance
          .stub(:publish)
          .and_return(true)
      end

      it 'should return success' do
        expect(subject.success?).to be_truthy
      end
    end

    context 'when event key is missing' do
      let(:event_key) { nil }

      let(:error) do
        "Missing event key for given payload: #{family_hash[:hbx_id]}"
      end

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure).to eq error
      end
    end

    context 'when input payload is invalid' do
      let(:error) do
        '[AcaEntities::Families::Family.new] :hbx_id is missing in Hash input'
      end

      before { family_hash.delete(:hbx_id) }

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure.message).to eq error
      end
    end
  end
end
