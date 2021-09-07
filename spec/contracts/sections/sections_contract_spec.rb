# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sections::SectionsContract do
  subject { described_class.new }

  let(:title) { 'UQHP deeterminatino main body' }
  let(:kind) { 'body' }

  let(:section_key) { 'main' }
  let(:section_item) { { title: title, kind: kind } }

  let(:required_params) { { sections: { section_key: section_item } } }
  let(:all_params) { required_params }

  context 'with a Section only' do
    it 'should pass validation' do
      expect(subject.call(required_params).success?).to be_truthy
      expect(subject.call(required_params).to_h).to eq required_params
    end
  end

  context 'with Section and SectionItem' do
    it 'should pass validation' do
      expect(subject.call(all_params).success?).to be_truthy
    end
    it 'should return validated params' do
      expect(subject.call(all_params).to_h).to eq all_params
    end
  end
end
