# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/section_params'

RSpec.describe Sections::Section do
  subject { described_class.new }
  include_context 'section_params'

  before { Sections::SectionModel.create_indexes }

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
    context "and a model with the given key doen't exist in the database" do
      it 'operation should succeed' do
        section_entity = described_class.call(all_params)
        result = section_entity.create_model

        expect(result.success?).to be_truthy
      end

      context 'and a model with the given key already exists in the database' do
        it 'database should have one Template record present' do
          result = Sections::SectionModel.all.to_a

          expect(result.size).to eq 1
          expect(result.first[:key]).to eq all_params[:key]
        end

        it 'opeation should fail' do
          expect {
            described_class.call(all_params).create_model
          }.to raise_error Mongo::Error::OperationFailure
        end
      end
    end
  end
end
