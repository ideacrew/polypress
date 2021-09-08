# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Events::EventRouteItemContract do
  subject { described_class.new }

  let(:attributes) do
    {
      determinations: [{ is_aqhp_eligible: false }, { is_uqhp_eligible: true }]
    }
  end
  let(:criteria) { 'is_uqhp_eligible == true' }
  let(:template_key) { 'uqhp_welcome_notice' }

  let(:required_params) { { template_key: template_key } }
  let(:optional_params) { { attributes: attributes, criteria: criteria } }
  let(:all_params) { required_params.merge(optional_params) }

  context 'Given gapped or invalid parameters' do
    context 'and parameters are empty' do
      it { expect(subject.call({}).success?).to be_falsey }
      it 'error message should include the first missing required parameter' do
        expect(subject.call({}).error?(required_params.keys.first)).to be_truthy
      end
    end
  end

  context 'Given valid parameters' do
    context 'and required parameters only' do
      it 'should pass validation' do
        result = subject.call(required_params)

        expect(result.success?).to be_truthy
        expect(result.to_h).to eq required_params
      end
    end

    context 'and required and optional parameters' do
      it 'should pass validation' do
        result = subject.call(all_params)

        expect(result.success?).to be_truthy
        expect(result.to_h).to eq all_params
      end
    end

    context 'and attributes are present but criteria in not present' do
      it 'should pass validation'
    end

    context 'and attributes are not present but criteria is present' do
      it 'should fail validation'
    end
  end
end
