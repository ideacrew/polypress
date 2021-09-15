# frozen_string_literal: true

require 'rails_helper'
require "#{Rails.root}/spec/shared_examples/eligibilities/application_response"

RSpec.describe Documents::Create do
  describe 'with valid arguments' do
    include_context 'application response from medicaid gateway'

    let(:entity) do
      ::AcaEntities::MagiMedicaid::Application.new(application_hash)
    end
    let(:title) { 'Uqhp Document' }
    let(:event_key) { 'magi_medicaid.determined_uqhp_eligible' }
    let(:body) do
      '<p>Uqhp Eligible Document for {{ family_reference.hbx_id }} {{ assistance_year }}</p>'
    end

    let(:template) do
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
        description: 'Uqhp Descriptoin'
      )
    end

    subject { described_class.new.call(key: template.key, entity: entity) }

    context 'when payload has all the required params' do
      it 'should return success' do
        expect(subject.success?).to be_truthy
      end

      it 'should create document' do
        expect(
          subject.success[:document].path.match?('tmp/Uqhp_Document.pdf')
        ).to be_truthy
      end
    end

    context 'when template body has unknown attributes' do
      let(:body) { '<p>Uqhp Eligible Document for {{ unknown_attribute }}</p>' }

      let(:error) do
        ['Liquid error (line 1): undefined variable unknown_attribute']
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
        expect(subject.failure.message).to eq error
      end
    end
  end
end
