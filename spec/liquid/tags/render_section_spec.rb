# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tags::RenderSection do
  subject { described_class.new }

  context 'given markup with a template, section and render_section tag' do
    let(:template_markup) { <<~TEMPLATE_MARKUP }
      <p>this is some introductory text</p>
      {% render_section 'my_section' %}
      <p>this text follow the section tag</p>
    TEMPLATE_MARKUP

    let(:_id) { 'xxyyzz' }
    let(:key) { 'typing_skills' }
    let(:title) { 'Typing drill' }
    let(:description) { 'A reusable address for customer letters' }
    let(:marketplace) { 'aca_individual' }
    let(:locale) { 'en' }
    let(:content_type) { 'text/html' }
    let(:body) do
      {
        markup: template_markup,
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

    let(:address_section_markup) { <<~SECTION_MARKUP }
      <h1>This is content from within a render_section tag</h1>
    SECTION_MARKUP

    let(:address_block_section) do
      Sections::SectionContract
        .new
        .call(
          _id: _id,
          key: 'my_section',
          title: 'My Section',
          marketplace: 'aca_individual',
          body: {
            markup: address_section_markup
          }
        )
        .to_h
    end

    let(:validated_base_template) do
      Templates::TemplateContract.new.call(base_template)
    end

    let(:validated_address_section) do
      Sections::SectionContract.new.call(address_block_section)
    end

    context "given markup with the render_section tag and the section doesn't exist" do
      # TODO
    end

    context 'given markup with the render_section tag and the section does exist' do
      before do
        Sections::Section.call(validated_address_section.to_h).create_model
      end

      let(:rendered_doc) { <<~RENDERED_DOC }
        <p>this is some introductory text</p>
        <h1>This is content from within a render_section tag</h1>\n
        <p>this text follow the section tag</p>
      RENDERED_DOC

      it 'should find the section and render into' do
        result =
          Templates::Render.new.call(template: validated_base_template.to_h)

        expect(result.success?).to be_truthy
        expect(result.success).to eq rendered_doc
      end
    end
  end
end
