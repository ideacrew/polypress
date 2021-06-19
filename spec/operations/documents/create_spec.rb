# frozen_string_literal: true

require 'rails_helper'
require "#{Rails.root}/spec/shared_examples/eligibilities/application_response"

RSpec.describe Documents::Create do
  describe 'with valid arguments' do
    include_context 'application response from medicaid gateway'

    let(:entity) { ::AcaEntities::MagiMedicaid::Application.new(application_hash) }
    let(:title) { 'Uqhp Document' }
    let(:event_key) { 'magi_medicaid.determined_uqhp_eligible' }
    let(:body) { '<p>Uqhp Eligible Document for {{ family_reference.hbx_id }} {{ assistance_year }}</p>' }
    let(:template_subject) { 'Uqhp Subject' }

    let(:template) do
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
      described_class.new.call(id: template.id, entity: entity)
    end

    context "when payload has all the required params" do
      it 'should return success' do
        expect(subject.success?).to be_truthy
      end

      it "should create document" do
        expect(subject.success[:document].path.match?("tmp/Uqhp_Document.pdf")).to be_truthy
      end
    end

    context "when template body has unknown attributes" do
      let(:body) { '<p>Uqhp Eligible Document for {{ unknown_attribute }}</p>' }

      let(:error) { ["Liquid error (line 1): undefined variable unknown_attribute"] }

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure.map(&:message)).to eq error
      end
    end

    context "when template body has syntax errors" do
      let(:body) { '<p>Uqhp Eligible Document for {% if %}</p>' }

      let(:error) { "Liquid syntax error (line 1): Syntax Error in tag 'if' - Valid syntax: if [expression]" }

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure.message).to eq error
      end
    end
  end
end
