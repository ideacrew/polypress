# frozen_string_literal: true

require 'rails_helper'
require "#{Rails.root}/spec/shared_examples/enrollments/family_response"

RSpec.describe Enrollments::GenerateAndPublishDocuments do
  describe 'with valid arguments' do
    include_context 'family response from enroll'

    let(:title) { 'Enrollment Notice' }
    let(:event_key) { 'enrollment_submitted' }
    let(:body) { '<p>Uqhp Eligible Document for {{ hbx_id }}</p>' }
    let(:template_subject) { 'Enrollment Notice Subject' }

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

    let!(:docs_insert) do
      FactoryBot.create(
        :template,
        key: 'outstanding_verifications_insert',
        body: body,
        title: title,
        subject: template_subject,
        category: 'aca_individual',
        recipient: 'AcaEntities::Families::Family',
        content_type: 'application/pdf',
        description: 'Uqhp Descriptoin'
      )
    end

    let(:application_entity) { ::AcaEntities::Families::Family.new(family_hash) }

    subject do
      described_class.new.call(family_hash: family_hash, event_key: event_key)
    end

    context "when payload has all the required params" do
      it 'should return success' do
        expect(subject.success?).to be_truthy
      end
    end

    context "when event key is missing" do
      let(:event_key) { nil }

      let(:error) { "Missing event key for given payload: #{family_hash[:hbx_id]}" }

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure).to eq error
      end
    end

    context "when input application hash is invalid" do
      let(:error) { '[AcaEntities::Families::Family.new] :hbx_id is missing in Hash input' }

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
