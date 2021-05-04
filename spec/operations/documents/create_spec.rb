# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Documents::Create do
  describe 'with valid arguments' do

    let(:family_hash) do
      { hbx_id: '1000',
        foreign_keys: foreign_keys,
        renewal_consent_through_year: 2014,
        min_verification_due_date: nil,
        vlp_documents_status: nil,
        family_members: family_member_params,
        households: household_params,
        documents: documents,
        special_enrollment_periods: special_enrollment_periods,
        broker_accounts: broker_accounts,
        general_agency_accounts: general_agency_accounts,
        irs_groups: irs_groups,
        payment_transactions: payment_transactions,
        updated_by: person_reference,
        timestamp: timestamp }
    end

    let(:dummy_struct) do
      Class.new(Dry::Struct) do
        attribute :name, Polypress::Types::String
        attribute :hbx_id, Polypress::Types::Integer
      end
    end

    let(:entity) do
      dummy_struct.new(name: 'Consumer 1', hbx_id: 734_535)
    end

    let(:title) { 'Uqhp Document' }
    let(:event_key) { 'magi_medicaid.determined_uqhp_eligible' }
    let(:body) { '<p>Uqhp Eligible Document for {{ hbx_id }} {{ name }}</p>' }
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
        expect(subject.success[0].path.match?("tmp/Uqhp_Document.pdf")).to be_truthy
      end
    end

    context "when template body has unknown attributes" do
      let(:body) { '<p>Uqhp Eligible Document for {{ unknown_attribute }}</p>' }

      let(:error) { ["Liquid error: undefined variable unknown_attribute"] }

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure.map(&:message)).to eq error
      end
    end

    context "when template body has syntax errors" do
      let(:body) { '<p>Uqhp Eligible Document for {% if %}</p>' }

      let(:error) { "Liquid syntax error: Syntax Error in tag 'if' - Valid syntax: if [expression]" }

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure.message).to eq error
      end
    end
  end
end
