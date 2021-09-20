# frozen_string_literal: true

require 'rails_helper'
require "#{Rails.root}/spec/shared_examples/eligibilities/application_response"

RSpec.describe MagiMedicaid::PublishDocument do
  describe 'with valid arguments' do
    include_context 'application response from medicaid gateway'

    let(:title) { 'Uqhp Document' }
    let(:event_key) { 'enroll.iap.applications.determined_uqhp_eligible' }
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
      described_class.new.call(entity: application_entity, template_model: template)
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

    context 'when event key is invalid' do
      let(:invalid_subject) do
        described_class.new.call(
          entity: application_entity,
          event_key: invalid_event_key
        )
      end

      let(:invalid_event_key) { 'invalid_event_key' }

      let(:error) { "Missing template model" }

      it 'should return failure' do
        expect(invalid_subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(invalid_subject.failure).to eq error
      end
    end

    context 'when template body has unknown attributes' do
      let(:body) do
        '<p>Uqhp Eligible Document for {{ unknown_attribute }}</p><p> {{ unknown_attribute_new }} </p> '
      end

      let(:error) do
        [
          'Liquid error (line 1): undefined variable unknown_attribute',
          'Liquid error (line 1): undefined variable unknown_attribute_new'
        ]
      end

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure.errors.map(&:to_s)).to eq error
      end
    end

    context 'when template body has syntax errors' do
      let(:body) { '<p>Uqhp Eligible Document for {% if %}</p>' }

      let(:error) do
        "Liquid syntax error (line 1): [:end_of_string] is not a valid expression in \"\""
      end

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure.to_s).to eq error
      end
    end
  end
end
