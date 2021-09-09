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
  let(:markup_section) do
    '<p>Now ruthless Ruth is a maid uncouth With scarlet cheeks and lips</p>'
  end

  let(:required_params) { { key: key, title: title, marketplace: marketplace } }
  let(:optional_params) do
    {
      _id: _id,
      description: description,
      locale: locale,
      content_type: content_type,
      print_code: print_code,
      marketplace: marketplace,
      author: author,
      updated_by: updated_by,
      created_at: created_at,
      updated_at: updated_at,
      markup_section: markup_section
    }
  end
  let(:all_params) { required_params.merge(optional_params) }
end
