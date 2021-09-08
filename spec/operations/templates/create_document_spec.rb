# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Templates::CreateDocument do
  subject { described_class.new }

  let(:template)

  context 'given a Template with no markup or sections' do
    it 'should render a document'
  end

  context 'given a Template with markup only and no section references' do
    it 'should render a document'
  end

  context 'given a Template with no markup and sections only' do
    it 'should render a document'
  end

  context 'given a Tempate with both markup and sections' do
    it 'should render a document'
  end
end
