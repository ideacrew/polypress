# frozen_string_literal: true

# rubocop:disable Style/BlockDelimiters

require 'rails_helper'
require 'shared_examples/section_params'

RSpec.describe Sections::Section do
  subject { described_class.new }
  include_context 'section_params'

  # before { Sections::SectionModel.create_indexes }

  context '.new' do
    context 'given missing or invalid parameters' do
      it 'operation should fail' do
        invalid_params = required_params.delete(required_params.keys.first)
        expect {
          described_class.new.call(invalid_params)
        }.to raise_error Dry::Struct::Error
      end
    end

    context 'given valid parameters' do
      it 'all params should pass validation' do
        values = Sections::SectionContract.new.call(all_params)

        expect(values.success?).to be_truthy
      end

      it 'required params only should pass validation' do
        result = described_class.call(required_params)
        expect(result.to_h).to eq required_params
      end

      it 'operation should succeed' do
        result = described_class.call(all_params)
        expect(result.to_h).to eq all_params
      end
    end
  end

  context '#create_model' do
    context 'and a new record is added to the database' do
      before { described_class.call(all_params).create_model }

      it 'database should have one Section record present' do
        result = Sections::SectionModel.all.to_a

        expect(result.size).to eq 1
        expect(result.first[:key]).to eq all_params[:key]
      end

      it ' second attempt to add record with same key should fail' do
        expect {
          described_class.call(all_params).create_model
        }.to raise_error Mongo::Error::OperationFailure
      end
    end
  end
end
# rubocop:enable Style/BlockDelimiters
