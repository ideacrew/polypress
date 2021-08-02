# frozen_string_literal: true

require "rails_helper"

RSpec.describe Documents::Upload do
  subject do
    described_class.new.call(params)
  end

  let(:tempfile) do
    tf = Tempfile.new('test.pdf')
    tf.write("DATA GOES HERE")
    tf.rewind
    tf
  end

  let(:doc_storage) do
    {
      :title => 'untitled',
      :language => 'en',
      :format => 'application/octet-stream',
      :source => 'polypress',
      :document_type => 'notice',
      :subjects => [{ :id => BSON::ObjectId.new.to_s, :type => 'test' }],
      :id => BSON::ObjectId.new.to_s,
      :extension => 'pdf'
    }
  end
  let(:resource_id) { '10011' }
  let(:params) do
    { resource_id: resource_id, title: 'some title', file: tempfile, user_id: nil }
  end

  describe 'given empty resource' do
    let(:resource_id) { nil }

    let(:error_message) do
      { :message => ['Resource id is nil'] }
    end

    it 'fails' do
      expect(subject).not_to be_success
      expect(subject.failure).to eq error_message
    end
  end

  describe ".validate_response" do
    let(:result) { ::Documents::Upload.new.send(:validate_response, doc_storage.transform_keys(&:to_sym)) }

    context "when response has empty subjects" do
      before do
        doc_storage[:subjects] = []
      end

      let(:error_message) do
        { :subjects => ['Missing attributes for subjects'] }
      end

      it "fails" do
        expect(result).not_to be_success
        expect(result.failure).to eq error_message
      end
    end

    context "when response has empty id" do
      before do
        doc_storage[:id] = ""
      end

      let(:error_message) do
        { :id => ['Doc storage Identifier is blank'] }
      end

      it "fails" do
        expect(result).not_to be_success
        expect(result.failure).to eq error_message
      end
    end

    context "when response has empty type" do
      before do
        doc_storage[:document_type] = ""
      end

      let(:error_message) do
        { :document_type => ['Document type is missing'] }
      end

      it "fails" do
        expect(result).not_to be_success
        expect(result.failure).to eq error_message
      end
    end

    context "when response has empty source" do
      before do
        doc_storage[:source] = ""
      end

      let(:error_message) do
        { :source => ['Invalid source'] }
      end

      it "fails" do
        expect(result).not_to be_success
        expect(result.failure).to eq error_message
      end
    end

    context "passing valid data" do
      it "success" do
        expect(result).to be_success
      end
    end
  end
end
