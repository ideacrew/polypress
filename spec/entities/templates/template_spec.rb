# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/template_params'

RSpec.describe Templates::Template do
  subject { described_class.new }
  include_context 'template_params'

  before { Templates::TemplateModel.create_indexes }

  context '.new' do
    context 'given missing or invalid parameters' do
      it 'operation should fail' do
        invalid_params = required_params.delete(required_params.keys.first)
        expect {
          described_class.call(invalid_params)
        }.to raise_error Dry::Struct::Error
      end
    end

    context 'given valid parameters' do
      it 'required params only should pass contract validation' do
        valid_params = Templates::TemplateContract.new.call(required_params)
        expect(valid_params.success?).to be_truthy
        expect(valid_params.to_h).to eq required_params
      end

      it 'all params should pass contract validation' do
        valid_params = Templates::TemplateContract.new.call(all_params)
        expect(valid_params.success?).to be_truthy
        expect(valid_params.to_h).to eq all_params
      end

      it 'all params should sucessfully create an entity' do
        valid_params = Templates::TemplateContract.new.call(all_params)
        expect(valid_params.to_h).to eq all_params
      end
    end
  end

  context '#create_model' do
    context 'and a new record is added to the database' do
      before do
        validated_template = Templates::TemplateContract.new.call(all_params)
        described_class.call(validated_template.to_h).create_model
      end

      it 'database should have one Template record present' do
        result = Templates::Find.new.call(scope_name: :all)
        expect(result.success.size).to eq 1
        expect(result.success.first[:key]).to eq all_params[:key]
      end

      it 'a second attempt to add record with same key should fail' do
        expect {
          described_class.call(all_params).create_model
        }.to raise_error Mongo::Error::OperationFailure
      end
    end
  end
end
