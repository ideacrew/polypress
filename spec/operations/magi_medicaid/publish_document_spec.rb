# frozen_string_literal: true

require 'rails_helper'
require "#{Rails.root}/spec/shared_examples/eligibilities/application_response"

RSpec.describe MagiMedicaid::PublishDocument do
  describe 'with valid arguments' do
    include_context 'application response from medicaid gateway'

    let(:title) { 'Uqhp Document' }
    let(:event_key) { 'magi_medicaid.determined_uqhp_eligible' }
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
      described_class.new.call(application_entity: application_entity, event_key: event_key)
    end

    context "when payload has all the required params" do
      it 'should return success' do
        expect(subject.success?).to be_truthy
      end
    end

    context "when event key is invalid" do
      let(:invalid_subject) { described_class.new.call(application_entity: application_entity, event_key: invalid_event_key) }

      let(:invalid_event_key) { 'invalid_event_key' }

      let(:error) { "Unable to find template with #{invalid_event_key} for family_hbx_id: #{application_entity.family_reference.hbx_id}" }

      it 'should return failure' do
        expect(invalid_subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(invalid_subject.failure).to eq error
      end
    end

    context "when template body has unknown attributes" do
      let(:body) { '<p>Uqhp Eligible Document for {{ unknown_attribute }}</p><p> {{ unknown_attribute_new }} </p> ' }

      let(:error) do
        ["Liquid error (line 1): undefined variable unknown_attribute", "Liquid error (line 1): undefined variable unknown_attribute_new"]
      end

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure.map(&:to_s)).to eq error
      end
    end

    context "when template body has syntax errors" do
      let(:body) { '<p>Uqhp Eligible Document for {% if %}</p>' }

      let(:error) { "Liquid syntax error (line 1): Syntax Error in tag 'if' - Valid syntax: if [expression]" }

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure.to_s).to eq error
      end
    end
  end
end
