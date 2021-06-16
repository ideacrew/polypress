# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Style/Documentation, Lint/ConstantDefinitionInBlock
RSpec.describe ::Publishers::DocumentMetaDataPublisher, dbclean: :after_each do

  module Operations
    class DocumentCreate
      include EventSource::Command

      def execute(payload)
        event = event('events.documents.document_created', attributes: payload).success
        event.publish
      end
    end
  end

  let(:payload) { { message: "Hello world!!" } }
  let(:publish_params) do
    {
      protocol: :amqp,
      publish_operation_name: 'polypress.document_builder.document_created'
    }
  end

  let(:connection_manager_instance) { EventSource::ConnectionManager.instance }
  let(:connection) { connection_manager_instance.find_connection(publish_params) }

  let(:publish_operation) { connection_manager_instance.find_publish_operation(publish_params) }
  let(:publish_proxy) { publish_operation.subject }
  let(:bunny_exchange) { publish_proxy.subject }

  it 'should create exchanges' do
    expect(bunny_exchange).to be_present
  end

  context "When valid event published" do

    it 'should publish payload with exchange' do
      expect(bunny_exchange).to receive(:publish).at_least(1).times
      Operations::DocumentCreate.new.execute(payload)
    end

    #  TODO verify exchange.on_return

  end
end
# rubocop:enable Style/Documentation, Lint/ConstantDefinitionInBlock