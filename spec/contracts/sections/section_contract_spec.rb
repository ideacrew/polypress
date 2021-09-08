# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sections::SectionContract do
  subject { described_class.new }

  let(:title) { 'UQHP determination main body' }
  let(:kind) { 'body' }
  let(:section_key) { 'main' }
  let(:section_item) { { section_key.to_s => { title: title, kind: kind } } }

  let(:required_params) { { sections: section_item } }

  context 'Given valid parameters' do
    context 'and required parameters only' do
      it 'should pass validation' do
        result = subject.call(required_params)

        expect(result.success?).to be_truthy
        expect(result.to_h).to eq required_params
      end
    end
  end
end
