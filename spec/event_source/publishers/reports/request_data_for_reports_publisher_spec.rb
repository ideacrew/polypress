# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Lint/ConstantDefinitionInBlock
RSpec.describe ::Publishers::Reports::RequestDataForReportsPublisher, dbclean: :after_each do

  module Operations
    module Reports
      class ReconPreAuditProcessor
        include EventSource::Command

        def execute(payload)
          event = event('events.reports.subscribers_list_requested', attributes: { payload: payload }).success
          event.publish
        end
      end
    end
  end

  module Operations
    module Reports
      class RequestCoverageHistoryForSubscriber
        include EventSource::Command

        def execute(payload)
          event = event('events.reports.coverage_history_for_subscriber_requested', attributes: { payload: payload }).success
          event.publish
        end
      end
    end
  end

  context "When valid event published" do
    let(:payload) { { carrier_hbx_id: "12345", year: Date.today.year } }
    let(:publish_params) do
      {
        protocol: :amqp,
        publish_operation_name: 'edi.reports.subscribers_list_requested'
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

    it 'should publish payload with exchange' do
      expect(bunny_exchange).to receive(:publish).at_least(1).times
      Operations::Reports::ReconPreAuditProcessor.new.execute(payload)
    end
  end

  context "When valid event published" do

    let(:payload) { { carrier_hbx_id: "12345", year: Date.today.year } }
    let(:publish_params) do
      {
        protocol: :amqp,
        publish_operation_name: 'edi.reports.coverage_history_for_subscriber_requested'
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

    it 'should publish payload with exchange' do
      expect(bunny_exchange).to receive(:publish).at_least(1).times
      Operations::Reports::RequestCoverageHistoryForSubscriber.new.execute(payload)
    end
  end
end
# rubocop:enable Lint/ConstantDefinitionInBlock
#