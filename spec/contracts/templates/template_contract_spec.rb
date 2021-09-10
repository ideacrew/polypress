# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Templates::TemplateContract do
  subject { described_class.new }

  let(:_id) { '123xyz' }
  let(:key) { 'uqhp_determination_notice' }
  let(:title) { 'UQHP Determination Notice' }

  let(:description) do
    'Notice of eligibility for purchasing Unassisted Qualified Health Plan Insurance'
  end
  let(:locale) { 'en' }
  let(:content_type) { 'text/html' }
  let(:print_code) { 'print_code_123' }
  let(:marketplace) { 'aca_individual' }
  let(:author) { 'abc123' }
  let(:updated_by) { '1abc123' }
  let(:created_at) { Time.now }
  let(:updated_at) { created_at }
  let(:body) do
    {
      markup: '<h1>Goodbye Bruel World!</h1>',
      content_type: 'text/xml',
      encoding_type: 'base64'
    }
  end

  let(:required_params) { { key: key, title: title, marketplace: marketplace } }
  let(:optional_params) do
    {
      _id: _id,
      description: description,
      locale: locale,
      body: body,
      content_type: content_type,
      print_code: print_code,
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

    context 'and the marketplace param is invalid' do
      let(:invalid_marketplace) { 'bogus_marketplace' }
      it 'should return an error message'
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
