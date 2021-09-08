# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sections::RenderSectionItem do
  subject { described_class.new }

  let(:title) { 'Typing drill' }
  let(:kind) { 'body' }
  let(:content_type) { 'text/html' }
  let(:section) { { title: title, kind: kind } }
  let(:body) { { content_type: content_type } }

  context 'given a SectionItem without markup content' do
    let(:section_item_body) { body.merge(markup: '') }
    let(:section_item) { section.merge(section_item_body: section_item_body) }
    it 'the parser should return an error' do
      result = subject.call(section_item: section_item)
      expect(result.failure?).to be_truthy
    end
  end

  context 'given a SectionItem with markup content' do
    let(:liquid_markup) { <<~MARKUP }
      <p>now is the time for all good men to come to the aid of their country</p>
    MARKUP

    let(:section_item_body) { body.merge(markup: liquid_markup) }
    let(:section_item) { section.merge(section_item_body: section_item_body) }

    it 'should render the content without error' do
      result = subject.call(section_item: section_item)

      expect(result.success?).to be_truthy
      expect(result.value!).to eq liquid_markup
    end

    context 'and markup includes variable tags without a liquid tag or attribute value' do
      let(:liquid_markup) { <<~MARKUP }
        <p>now is the time for all good {{ gender }} to come to the aid of their country</p>
      MARKUP

      let(:section_item_body) { body.merge(markup: liquid_markup) }
      let(:section_item) { section.merge(section_item_body: section_item_body) }
      it 'the parser should return an error' do
        result = subject.call(section_item: section_item)
        expect(result.failure?).to be_truthy
      end
    end

    context 'and markup includes variable tags with a matching liquid tag value' do
      let(:liquid_markup) { <<~MARKUP }
        {% assign gender = 'women' %}
        <p>now is the time for all good {{ gender }} to come to the aid of their country</p>
      MARKUP

      let(:rendered_doc) { <<~RENDERED_DOC }
        <p>now is the time for all good women to come to the aid of their country</p>
      RENDERED_DOC

      let(:section_item_body) { body.merge(markup: liquid_markup) }
      let(:section_item) { section.merge(section_item_body: section_item_body) }
      it 'should render the content without error substituting the liquid variable' do
        result = subject.call(section_item: section_item)

        expect(result.success?).to be_truthy
        expect(result.value!.lstrip!).to eq rendered_doc
      end
    end

    context 'and markup includes variable tags with a matching attribute value' do
      let(:liquid_markup) { <<~MARKUP }
        <p>now is the time for all good {{ gender }} to come to the aid of their country</p>
      MARKUP

      let(:rendered_doc) { <<~RENDERED_DOC }
        <p>now is the time for all good women to come to the aid of their country</p>
      RENDERED_DOC

      let(:section_item_body) { body.merge(markup: liquid_markup) }
      let(:section_item) { section.merge(section_item_body: section_item_body) }
      let(:attributes) { { gender: 'women' } }

      it 'should render the content without error substituting the passsed attribute' do
        result =
          subject.call({ section_item: section_item, attributes: attributes })

        expect(result.success?).to be_truthy
        expect(result.value!).to eq rendered_doc
      end
    end

    context 'and markup includes variable tags with a both a liquid tag and a matching attribute value' do
      let(:liquid_markup) { <<~MARKUP }
        {% assign gender = 'people' %}
        <p>now is the time for all good {{ gender }} to come to the aid of their country</p>
      MARKUP

      let(:rendered_doc) { <<~RENDERED_DOC }
        <p>now is the time for all good people to come to the aid of their country</p>
      RENDERED_DOC

      let(:section_item_body) { body.merge(markup: liquid_markup) }
      let(:section_item) { section.merge(section_item_body: section_item_body) }
      let(:attributes) { { gender: 'women' } }

      it 'should render the content without error substituting the liquid variable' do
        result =
          subject.call({ section_item: section_item, attributes: attributes })

        expect(result.success?).to be_truthy
        expect(result.value!.lstrip).to eq rendered_doc
      end
    end
  end

  context 'given a SectionItem with a PDF content' do
      it 'should render the content without error' do
  end
end
