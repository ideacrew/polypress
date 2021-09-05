require 'rails_helper'

RSpec.describe Tags::Tag do
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
      it { expect(subject.call({}).error?(:name)).to be_truthy }
    end
  end

  context 'Given valid parameters' do
    context 'and required parameters only' do
      it { expect(subject.call(required_params).success?).to be_truthy }
      it { expect(subject.call(required_params).to_h).to eq required_params }
    end

    context 'and required and optional parameters' do
      it { expect(subject.call(all_params).success?).to be_truthy }
      it { expect(subject.call(all_params).to_h).to eq all_params }
    end
  end
end
