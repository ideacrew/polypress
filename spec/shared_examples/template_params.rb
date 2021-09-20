# frozen_string_literal: true

RSpec.shared_context 'template_params' do
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

  let(:publisher_event_name) { 'on_polypress.greeting_notice.published' }
  let(:publisher) { { event_name: publisher_event_name } }

  let(:subscriber_event_name) { "enroll_app.customer_created_#{rand(20)}" }
  let(:subscriber) { { event_name: subscriber_event_name } }

  let(:required_params) { { key: key, title: title, marketplace: marketplace } }
  let(:optional_params) do
    {
      _id: _id,
      description: description,
      locale: locale,
      body: body,
      content_type: content_type,
      print_code: print_code,
      publisher: publisher,
      subscriber: subscriber,
      author: author,
      updated_by: updated_by,
      created_at: created_at,
      updated_at: updated_at
    }
  end
  let(:all_params) { required_params.deep_merge(optional_params) }
end
