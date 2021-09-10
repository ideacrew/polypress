# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/section_params'

RSpec.describe Sections::Find, dbclean: :after_each do
  subject { described_class.new }
  include_context 'section_params'

  context 'with some records added to the database' do
    let!(:section_recs) do
      3.times do |index|
        Sections::Section.new(all_params.merge(key: index.to_s)).create_model
      end
    end

    context 'the find operation should return records matching criteria' do
      context '#find by_key' do
        it 'should find the correct record' do
          result = subject.call(scope_name: :by_key, options: { value: '0' })

          expect(result.success?).to be_truthy
          expect(result.success.size).to eq 1
        end
      end

      context '#find all' do
        it 'should find all records' do
          result = subject.call(scope_name: :all)

          expect(result.success?).to be_truthy
          expect(result.success.size).to eq 3
        end
      end
    end
  end
end
