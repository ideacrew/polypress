# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/template_params'

RSpec.describe Templates::Template do
  subject { described_class.new }
  include_context 'template_params'

  context '.new' do
    context 'given missing or invalid parameters' do
      it 'operation should fail' do
        invalid_params = required_params.delete(required_params.keys.first)
        expect do
          described_class.new.call(invalid_params)
        end.to raise_error Dry::Struct::Error
      end
    end

    context 'given valid parameters' do
      it 'all params should pass validation' do
        values = Templates::TemplateContract.new.call(all_params)

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
      it 'database should have one Template record present' do
        result = Templates::TemplateModel.all.to_a

        expect(result.size).to eq 1
        expect(result.first[:key]).to eq all_params[:key]
      end

      it 'a second attempt to add record with same key should fail' do
        expect do
          described_class.call(all_params).create_model
        end.to raise_error Mongo::Error::OperationFailure
      end
    end
  end
end
