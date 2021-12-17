# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Reports::RequestCoverageHistoryForSubscriber do

  describe 'with valid arguments' do
    let(:audit_report_execution) { FactoryBot.create(:audit_report_execution)}
    let(:audit_report_datum) { FactoryBot.create(:audit_report_datum, audit_report_execution: audit_report_execution)}
    let(:coverage_history_setting) { double(item: "http://localhost:3004/api/event_source/enrolled_subjects") }
    let(:user_token) { double(item: "some token") }
    let(:feature_ns) { double }

    before :each do
      allow(feature_ns).to receive(:setting).with(:gluedb_enrolled_subjects_uri).and_return(coverage_history_setting)
      allow(feature_ns).to receive(:setting).with(:gluedb_user_access_token).and_return(user_token)
      allow(PolypressRegistry).to receive(:[]).with(:gluedb_integration).and_return(feature_ns)
    end

    subject do
      described_class.new.call({
                                 audit_report_execution: audit_report_execution,
                                 audit_report_datum: audit_report_datum
                               })
    end

    context 'fetch coverage history for subscriber and update audit report datum' do
      before do
        stub_request(:get, "http://localhost:3004/api/event_source/enrolled_subjects/12345?hios_id=12345&user_token=some%20token&year=2022")
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Faraday v1.4.3'
            }
          )
          .to_return(status: 200, body: "test".to_json, headers: {})
      end

      it 'should return success' do
        expect(subject.success?).to be_truthy
        expect(audit_report_datum.payload).to eq "test".to_json
      end
    end
  end
end