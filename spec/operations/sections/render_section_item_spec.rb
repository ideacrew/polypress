require 'rails_helper'

RSpec.describe Sections::RenderSectionItem do
  subject { described_class.new }
  let(:title) { 'Typing drill' }
  let(:kind) { 'body' }
  let(:content_type) { 'text/html' }
  context 'given a SectionItem without markup content' do
    let(:section_item_body) { { markup: '', content_type: content_type } }

    let(:section_item) do
      { title: title, kind: kind, section_item_body: section_item_body }
    end
    it 'the parser should return an error' do
      result = subject.call(section_item: section_item)
      expect(result.failure?).to be_truthy
    end
  end

  context 'given a SectionItem with simple markup content' do
    let(:liquid_markup) { <<~MARKUP }
      <p>now is the time for all good men to come to the aid of their country</p>
    MARKUP

    let(:section_item_body) do
      { markup: liquid_markup, content_type: content_type }
    end

    let(:section_item) do
      { title: title, kind: kind, section_item_body: section_item_body }
    end

    it 'should render the content without error' do
      result = subject.call(section_item: section_item)

      expect(result.success?).to be_truthy
      expect(result.value!).to eq liquid_markup
    end

    context 'and markup includes variable tags without a liquid tag or attribute value' do
      let(:liquid_markup) { <<~MARKUP }
        <p>now is the time for all good {{ gender }} to come to the aid of their country</p>
      MARKUP

      let(:section_item_body) do
        { markup: liquid_markup, content_type: content_type }
      end

      let(:section_item) do
        { title: title, kind: kind, section_item_body: section_item_body }
      end

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

      let(:section_item_body) do
        { markup: liquid_markup, content_type: content_type }
      end

      let(:section_item) do
        { title: title, kind: kind, section_item_body: section_item_body }
      end

      it 'should render the content without error substituting the assigned variable' do
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

      let(:section_item_body) do
        { markup: liquid_markup, content_type: content_type }
      end

      let(:section_item) do
        { title: title, kind: kind, section_item_body: section_item_body }
      end

      let(:attributes) { { gender: 'women' } }

      it 'should render the content without error substituting the assigned attribute' do
        result =
          subject.call({ section_item: section_item, attributes: attributes })

        expect(result.success?).to be_truthy
        expect(result.value!).to eq rendered_doc
      end
    end
  end

  context 'given a Section::SectionItem with a PDF payload' do
    it 'should render the PDF'
  end
end
