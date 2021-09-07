# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sections::SectionItemContract do
  subject { described_class.new }

  let(:title) { 'UQHP deeterminatino main body' }
  let(:kind) { 'body' }
  let(:description) { 'UQHP determination notice content' }
  let(:section_body) { { markup: '', content_type: 'text/xml' } }

  let(:created_at) { Time.now }
  let(:updated_at) { created_at }
  let(:updated_by) { 'ad34df232456f' }
  let(:author) { 'ad34df232456f' }

  let(:required_params) { { title: title, kind: kind } }

  let(:optional_params) do
    {
      description: description,
      section_body: section_body,
      created_at: created_at,
      updated_at: updated_at,
      updated_by: updated_by,
      author: author
    }
  end
  let(:all_params) { required_params.merge(optional_params) }

  context 'Given gapped or invalid parameters' do
    context 'and parameters are empty' do
      it { expect(subject.call({}).success?).to be_falsey }
      it do
        expect(subject.call({}).error?(required_params.keys.first)).to be_truthy
      end
    end
    context 'and template kind is invalid' do
      let(:invalid_kind) { 'invalid_kind_value' }

      it 'should fail validation' do
        result = subject.call({ kind: invalid_kind })
        invalid_kind_error = ['must be one of: body, component']

        expect(result.success?).to be_falsey
        expect(result.errors[:kind]).to eq invalid_kind_error
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
