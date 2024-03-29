# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tags::TagContract do
  subject { described_class.new }

  let(:namespace) { 'families.fammily_id_1' }
  let(:key) { :renewal_consent_through_year }
  let(:value) { 2025 }
  let(:description) do
    'The year through which financial assistance customer has granted permission to verify income'
  end

  let(:required_params) { { key: key, value: value } }
  let(:optional_params) { { description: description, namespace: namespace } }
  let(:all_params) { required_params.merge(optional_params) }

  context 'Given gapped or invalid parameters' do
    context 'and parameters are empty' do
      it { expect(subject.call({}).success?).to be_falsey }
      it do
        expect(subject.call({}).error?(required_params.keys.first)).to be_truthy
      end
    end
  end

  context 'Given valid parameters' do
    context 'and required parameters only' do
      let(:full_key) { key.to_s }

      it { expect(subject.call(required_params).success?).to be_truthy }

      it 'the :full_key parameter should be stringified key' do
        expect(subject.call(required_params).to_h[:full_key]).to eq full_key
      end

      it 'output values should match input parameters' do
        # rubocop:disable Layout/FirstArgumentIndentation
        expect(subject.call(required_params).to_h).to eq required_params.merge!(
             full_key: full_key
           )
      end
    end

    context 'and required and optional parameters' do
      let(:full_key) { [namespace, key.to_s].join('.') }

      it { expect(subject.call(all_params).success?).to be_truthy }

      it 'the :full_key parameter should concat namespace + key' do
        expect(subject.call(all_params).to_h[:full_key]).to eq full_key
      end

      it 'output values should match input parameters' do
        expect(subject.call(all_params).to_h).to eq all_params.merge!(
             full_key: full_key
           )
        # rubocop:enable Layout/FirstArgumentIndentation
      end
    end
  end
end
