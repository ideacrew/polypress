# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/enrollments/family_response'

RSpec.describe Sections::SectionBodyContract do
  subject { described_class.new }

  let(:content_type) { 'text/html' }
  let(:markup) { <<~MARKUP }
    {% assign primary_member = family.family_members | where: 'primary_member', true | first %}
    {% assign recipient = primary_member.person %}
    {% assign mailing_address = recipient.addresses | where: 'kind', 'mailing' | first %}

    <p>{{ recipient.person_name.first_name | capitalize }} {{ recipient.person_name.first_name | capitalize }}</p>
    <p>{{ mailing_address.address_line_1 }}</p>
    {% if mailing_address.address_line_2 and mailing_address.address_line_2.size > 0 %}
      <p>{{ mailing_address.address_line_2 }}</p>
    {% endif %}
    {% if mailing_address.address_line_3 and mailing_address.address_line_3.size > 0 %}
      <p>{{ mailing_address.address_line_3 }}</p>
    {% endif %}
    <p>{{ mailing_address.city }}, {{ mailing_address.state | upcase }} {{ mailing_address.zip }}</p>
  MARKUP

  let(:required_params) { {} }
  let(:optional_params) { { content_type: content_type, markup: markup } }
  let(:all_params) { optional_params }

  context 'Given valid parameters' do
    context 'and required and optional parameters' do
      it 'should pass validiation' do
        result = subject.call(all_params)

        expect(result.success?).to be_truthy
        expect(result.to_h).to eq all_params
      end
    end
  end
end
