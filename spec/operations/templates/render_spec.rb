# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Templates::Render do
  subject { described_class.new }

  let(:_id) { 'xxyyzz' }
  let(:key) { 'typing_skills' }
  let(:title) { 'Typing drill' }
  let(:description) { 'A reusable address for customer letters' }
  let(:marketplace) { 'aca_individual' }
  let(:locale) { 'en' }
  let(:content_type) { 'text/html' }
  let(:body) do
    {
      markup: '<h1>Hello World!</h1>',
      content_type: 'text/xml',
      encoding_type: 'base64'
    }
  end
  let(:print_code) { 'ivl-022' }
  let(:author) { 'klm555' }
  let(:updated_by) { author }
  let(:published_at) { Time.now }
  let(:created_at) { Time.now }
  let(:updated_at) { Time.now }

  let(:base_template) do
    {
      _id: _id,
      key: key,
      title: title,
      marketplace: marketplace,
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

  context 'given a Template without markup content' do
    let(:template) { base_template.deep_merge(body: { markup: '' }) }

    it 'the parser should return an error' do
      result = subject.call(template: template)
      expect(result.failure?).to be_truthy
    end
  end

  context 'given a Template with markup content' do
    let(:liquid_markup) { <<~MARKUP }
      <p>now is the time for all good men to come to the aid of their country</p>
    MARKUP

    let(:template) { base_template.deep_merge(body: { markup: liquid_markup }) }

    it 'should render the content without error' do
      result = subject.call(template: template)

      expect(result.success?).to be_truthy
      expect(result.value!).to eq liquid_markup
    end

    context 'and markup includes variable tags without a liquid tag or attribute value' do
      let(:liquid_markup) { <<~MARKUP }
        <p>now is the time for all good {{ gender }} to come to the aid of their country</p>
      MARKUP

      let(:template) do
        base_template.deep_merge(body: { markup: liquid_markup })
      end

      it 'the parser should return an error' do
        result = subject.call(template: template)
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

      let(:template) do
        base_template.deep_merge(body: { markup: liquid_markup })
      end

      it 'should render the content without error substituting the liquid variable' do
        result = subject.call(template: template)

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

      let(:template) do
        base_template.deep_merge(body: { markup: liquid_markup })
      end
      let(:attributes) { { gender: 'women' } }

      it 'should render the content without error substituting the passsed attribute' do
        result = subject.call({ template: template, attributes: attributes })

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

      let(:template) do
        base_template.deep_merge(body: { markup: liquid_markup })
      end
      let(:attributes) { { gender: 'women' } }

      it 'should render the content without error substituting the liquid variable' do
        result = subject.call({ template: template, attributes: attributes })

        expect(result.success?).to be_truthy
        expect(result.value!.lstrip).to eq rendered_doc
      end
    end
  end

  context 'given a Template with a PDF content' do
    it 'should render the content without error'
  end
end
