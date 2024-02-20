# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/template_params'

RSpec.describe Bodies::BodyModel, type: :model do
  include_context 'template_params'
  pending "add some examples to (or delete) #{__FILE__}"

  context 'given invalid parameters' do
    it 'should not pass contract validation' do
      body[:markup] = '`env`'
      expect(described_class.create(body).errors.full_messages).to eq ["has invalid elements"]
    end
  end
end
