# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sections::FindSectionItem do
  subject { described_class.new }

  context 'Given gapped or invalid parameters' do
    context 'and parameters are empty' do
      it { expect(subject.call({}).success?).to be_falsey }
      it 'should fail validation' do
        expect(subject.call({}).error?(required_params.keys.first)).to be_truthy
      end
    end
  end

  context 'Operation is called without params' do
    let(:error_message) { 'must provide :key paramater' }
    it 'should fail validation' do
      expect(described_class.new.call({}).success?).to be_falsey
      expect(described_class.new.call({}).failure).to eq error_message
    end
  end

  context 'Operation is called using a :key with no matching database record' do
    let(:key) { 'bogus_key' }
    let(:error_message) { "Unable to find section with key: #{key}" }

    it 'should not find a matching record' do
      expect(subject.call(key: key).success?).to be_falsey
      expect(subject.call(key: key).failure).to eq error_message
    end
  end

  context 'A section record is added to the database' do
    let(:key) { 'section_key_name' }
    let(:title) { 'UQHP determination main body' }
    let(:kind) { 'component' }
    let(:section_item) { { section_key.to_s => { title: title, kind: kind } } }
    let(:section) { { title: title, kind: kind, key: key } }

    it 'should find and return a Transaction hash for the supplied :correlation_id' do
      let(:section) do
        Sections::AddSectionItem.new.call(
          correlation_id: correlation_id,
          activity: request_activity
        )
      end

      result =
        described_class.new.call(
          correlation_id: transaction.value![:correlation_id]
        )
      expect(::Transaction.all.size).to be > 0
      expect(result.success?).to be_truthy
      expect(result.value!.to_h[:correlation_id]).to eq correlation_id
    end
  end
end
