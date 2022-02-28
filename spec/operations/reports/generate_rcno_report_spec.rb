# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Reports::GenerateRcnoReport do
  include Dry::Monads[:result, :do]

  let!(:audit_report_datum) { FactoryBot.create_list(:audit_report_datum, 100, payload: json_payload, hios_id: "1234567")}
  let(:enrollee) do
    {
      enrollee_demographics: demographics,
      first_name: "dummy",
      middle_name: nil,
      last_name: "dummy",
      name_sfx: nil,
      hbx_member_id: "1234567",
      premium_amount: "20.0",
      coverage_start: "2021-11-10",
      coverage_end: "2021-11-10",
      coverage_status: "test",
      relationship_status_code: "self",
      issuer_assigned_member_id: "12345",
      issuer_assigned_policy_id: nil,
      is_subscriber: "true",
      is_responsible_party: "false",
      addresses: addresses,
      phones: phones,
      emails: emails,
      segments: segments
    }
  end

  let(:demographics) do
    {
      dob: "2020-01-01",
      ssn: "999999999",
      gender_code: "F",
      tobacco_use_code: "unknown"
    }
  end

  let(:segments) do
    [
      {
        id: "1100500-45009-1100500-20220101-20221231",
        effective_start_date: "2021-10-12",
        effective_end_date: "2021-10-12",
        individual_premium_amount: "21.0",
        individual_responsible_amount: nil,
        total_premium_amount: "32.0",
        total_responsible_amount: "32.0",
        aptc_amount: "23.1",
        csr_variant: "0"
      }
    ]
  end

  let(:addresses) do
    [
      {
        kind: "home",
        address_1: "dummy",
        address_2: "",
        address_3: "",
        city: "dummy",
        county: "",
        state: "ME",
        location_state_code: nil,
        full_text: nil,
        zip: "20009",
        country_name: ""
      }
    ]
  end

  let(:phones) do
    [
      {
        kind: "home",
        country_code: "",
        area_code: "202",
        number: "123455",
        extension: "",
        primary: true,
        full_phone_number: "202123455"
      }
    ]
  end

  let(:emails) do
    [
      {
        kind: "home",
        address: "test@gmail.com"
      }
    ]
  end

  let!(:policy_params) do
    {
      policy_id: '1001',
      enrollment_group_id: "10010",
      hios_plan_id: '1001',
      qhp_id: '1001',
      allocated_aptc: "20.0",
      elected_aptc: "20.0",
      applied_aptc: "20.0",
      csr_amt: nil,
      total_premium_amount: "20.0",
      total_responsible_amt: "20.0",
      coverage_kind: "health",
      term_for_np: "false",
      rating_area: "RDC",
      service_area: nil,
      last_maintenance_date: "2021-11-10",
      last_maintenance_time: "16:40:41",
      aasm_state: "submitted",
      exchange_subscriber_id: "12345",
      effectuation_status: "Y",
      insurance_line_code: "test",
      csr_variant: nil,
      enrollees: [enrollee],
      aptc_maximums: [],
      aptc_credits: []
    }
  end

  let(:json_payload) do
    @result = AcaEntities::Contracts::Policies::PolicyContract.new.call(policy_params)
    [@result.to_h].to_json
  end

  after :each do
    FileUtils.rm_rf("#{Rails.root}/rcno_carrier_hios_id_#{audit_report_datum.first&.hios_id}.csv")
  end

  describe "with valid arguments" do
    let(:output_file) { "#{Rails.root}/rcno_carrier_hios_id_#{audit_report_datum.first&.hios_id}.csv" }

    it "should be success" do
      subject = described_class.new
      payload_hash = { payload: { carrier_hios_id: audit_report_datum.first&.hios_id } }
      File.stub(:exist?).and_return(true)
      allow(subject).to receive(:fetch_rcni_file_path).and_return(Success("#{Rails.root}/spec/test_data/RCNI_33653.txt"))
      result = subject.call({ :payload => payload_hash.to_json })
      expect(result.success?).to eq true
      expect(File.exist?(output_file)).to eq true
    end
  end
end