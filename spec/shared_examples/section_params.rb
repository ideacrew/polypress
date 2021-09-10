# frozen_string_literal: true

RSpec.shared_context 'section_params' do
  let(:_id) { 'xyz321' }
  let(:key) { 'address_block' }

  let(:title) { 'Address Block' }
  let(:description) { 'A reusable address for customer letters' }
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

  let(:required_params) { { key: key, section_item: { title: title } } }

  let(:optional_params) do
    {
      _id: _id,
      section_item: {
        description: description,
        body: body,
        locale: locale,
        author: author,
        updated_by: updated_by,
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  let(:all_params) { required_params.deep_merge(optional_params) }
end
