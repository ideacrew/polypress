# frozen_string_literal: true

require 'rails_helper'
require "#{Rails.root}/spec/shared_examples/eligibilities/application_response"

RSpec.describe MagiMedicaid::PublishUqhpEligibleDocument do
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

    subject do
      described_class.new.call(application: application_hash, event_key: event_key)
    end

    context "when payload has all the required params" do
      it 'should return success' do
        expect(subject.success?).to be_truthy
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

    context "when event key is invalid" do
      let(:invalid_subject) { described_class.new.call(application: application_hash, event_key: invalid_event_key) }

      let(:invalid_event_key) { 'invalid_event_key' }

      let(:error) { "No template found for the given #{invalid_event_key} & for resource #{application_hash[:family_reference][:hbx_id]}" }

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
        ["Liquid error (line 147): undefined variable unknown_attribute", "Liquid error (line 147): undefined variable unknown_attribute_new"]
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

      let(:error) { "Liquid syntax error (line 147): Syntax Error in tag 'if' - Valid syntax: if [expression]" }

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure.to_s).to eq error
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
