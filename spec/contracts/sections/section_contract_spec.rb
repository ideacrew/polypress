# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sections::SectionContract do
  subject { described_class.new }

  let(:_id) { 'xyz321' }
  let(:key) { 'address_block' }

  let(:title) { 'Address Block' }
  let(:description) { 'UQHP determination notice content' }
  let(:marketplace) { 'aca_individual' }
  let(:locale) { 'en' }
  let(:body) do
    {
      markup: '<h1>Hollo World!</h1>',
      content_type: 'text/xml',
      encoding_type: 'base64'
    }
  end

  let(:author) { 'ad34df232456f' }
  let(:updated_by) { author }
  let(:created_at) { Time.now }
  let(:updated_at) { created_at }

  let(:required_params) { { key: key, title: title, marketplace: marketplace } }

  let(:optional_params) do
    {
      _id: _id,
      description: description,
      body: body,
      locale: locale,
      author: author,
      updated_by: updated_by,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  let(:all_params) { required_params.deep_merge(optional_params) }

  context 'Given gapped or invalid parameters' do
    context 'and parameters are empty' do
      it { expect(subject.call({}).success?).to be_falsey }
      it 'should fail validation' do
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
  end
end
