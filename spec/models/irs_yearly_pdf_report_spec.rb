# frozen_string_literal: true

require 'rails_helper'
require "#{Rails.root}/spec/shared_examples/enrollments/family_response"

RSpec.describe IrsYearlyPdfReport, type: :model do
  describe "initialization" do
    include_context 'family response from enroll'

    let(:title) { '1095A Tax Document' }
    let(:print_code) { 'IVLCAP' }
    let(:family_contract) { AcaEntities::Contracts::Families::FamilyContract.new.call(family_hash) }
    let(:entity) { AcaEntities::Families::Family.new(family_contract.to_h) }
    let(:insurance_agreement) { entity.to_h[:households][0][:insurance_agreements][0] }
    let(:insurance_policy) { insurance_agreement[:insurance_policies][0]}
    let(:tax_household) { insurance_policy[:aptc_csr_tax_households][0] }
    let(:included_hbx_ids) { tax_household[:covered_individuals].map { |individual| individual[:person][:hbx_id] } }
    let(:recipient) { entity.to_h[:family_members][0] }

    it "sets correct calendar_year fetch correct irs_document based on calendar_year" do
      params = { tax_household: tax_household,
                 recipient: recipient,
                 insurance_policy: insurance_policy,
                 insurance_agreement: insurance_agreement,
                 included_hbx_ids: included_hbx_ids }
      irs_yearly_pdf_report = IrsYearlyPdfReport.new(params)
      reporting_year = insurance_agreement[:plan_year].to_i
      expect(irs_yearly_pdf_report.instance_variable_get(:@reporting_year)).to eq(reporting_year)
      expect(irs_yearly_pdf_report.instance_variable_get(:@calender_year)).to eq(reporting_year)
      expect(irs_yearly_pdf_report.fetch_irs_form_template).to eq("#{Rails.root}/lib/pdf_templates/#{reporting_year}_1095A_form.pdf")
    end

    it "tax form should exist" do
      params = { tax_household: tax_household,
                 recipient: recipient,
                 insurance_policy: insurance_policy,
                 insurance_agreement: insurance_agreement,
                 included_hbx_ids: included_hbx_ids }
      IrsYearlyPdfReport.new(params)
      reporting_year = insurance_agreement[:plan_year].to_i
      expect(File.exist?("#{Rails.root}/lib/pdf_templates/#{reporting_year}_1095A_form.pdf")).to eq true
    end

    context "spouse details" do
      context "Primary and Spouse are married filing jointly and both are enrolled" do
        it "set spouse details" do
          params = { tax_household: tax_household,
                     recipient: recipient,
                     insurance_policy: insurance_policy,
                     insurance_agreement: insurance_agreement,
                     included_hbx_ids: included_hbx_ids }
          irs_yearly_pdf_report = IrsYearlyPdfReport.new(params)
          expect(irs_yearly_pdf_report.instance_variable_get(:@spouse)).to be_present
          spouse_details = irs_yearly_pdf_report.instance_variable_get(:@spouse)
          recipient_details = irs_yearly_pdf_report.instance_variable_get(:@recipient)
          expect(spouse_details.dig(:family_member_reference, :first_name)).to be_present
          expect(spouse_details.dig(:family_member_reference, :family_member_hbx_id)).to eq "1025992"
          expect(recipient_details.dig(:person, :hbx_id)).to eq "476"
        end
      end

      context "Primary and Spouse are married filing jointly and only spouse is enrolled and is also recipient" do
        let(:covered_individuals) do
          [
            {
              coverage_start_on: current_date.beginning_of_year,
              coverage_end_on: current_date.end_of_year,
              person: {
                hbx_id: "1025992",
                person_name: { first_name: "spouse", last_name: "test" },
                person_demographics: {
                  gender: "female",
                  encrypted_ssn: "yobheUbYUK2Abfc6lrq37YQCsPgBL8lLkw==\n",
                  dob: Date.today - 10.years
                },
                person_health: {},
                is_active: true,
                addresses: addresses,
                emails: [
                  {
                    kind: "home",
                    address: "test@gmail.com"
                  }
                ]
              },
              relation_with_primary: "spouse",
              filer_status: "tax_filer"
            }
          ]
        end

        it "set primary as the spouse" do
          params = { tax_household: tax_household,
                     recipient: recipient,
                     insurance_policy: insurance_policy,
                     insurance_agreement: insurance_agreement,
                     included_hbx_ids: included_hbx_ids }
          irs_yearly_pdf_report = IrsYearlyPdfReport.new(params)
          expect(irs_yearly_pdf_report.instance_variable_get(:@spouse)).to be_present
          spouse_details = irs_yearly_pdf_report.instance_variable_get(:@spouse)
          recipient_details = irs_yearly_pdf_report.instance_variable_get(:@recipient)
          expect(spouse_details.dig(:family_member_reference, :family_member_hbx_id)).to eq "1025992"
          expect(recipient_details.dig(:person, :hbx_id)).to eq "476"
        end
      end
    end

    context "#fetch_insurance_provider_title" do
      context "tax_notices setting is enabled" do
        let(:setting) { double }
        before :each do
          mapping = { 'Anthem Blue Cross and Blue Shield': "Anthem Health Plans of Maine Inc",
                      'Harvard Pilgrim Health Care': "Harvard Pilgrim Health Care Inc",
                      'Community Health Options': "Maine Community Health Options",
                      'Taro Health': "Taro Health Plan of Maine Inc" }
          allow(PolypressRegistry).to receive(:[]).with(:modify_carrier_legal_names).and_return(setting)
          allow(setting).to receive(:settings).with(:carrier_names_mapping).and_return(double(item: mapping))
        end

        context "when insurance_provider is in mapping" do
          let(:provider_title) { "Community Health Options" }

          it "returns correct mapping title for insurance_provider" do
            params = { tax_household: tax_household,
                       recipient: recipient,
                       insurance_policy: insurance_policy,
                       insurance_agreement: insurance_agreement,
                       included_hbx_ids: included_hbx_ids }
            irs_yearly_pdf_report = IrsYearlyPdfReport.new(params)
            result = irs_yearly_pdf_report.fetch_insurance_provider_title(provider_title)
            expect(result).to eq("Maine Community Health Options")
          end
        end

        context "when insurance_provider is not in mapping" do
          let(:provider_title) { "Community Health Options Inc" }

          it "returns provider_title as is" do
            params = { tax_household: tax_household,
                       recipient: recipient,
                       insurance_policy: insurance_policy,
                       insurance_agreement: insurance_agreement,
                       included_hbx_ids: included_hbx_ids }
            irs_yearly_pdf_report = IrsYearlyPdfReport.new(params)
            result = irs_yearly_pdf_report.fetch_insurance_provider_title(provider_title)
            expect(result).to eq("Community Health Options Inc")
          end
        end
      end

      context "tax_notices setting is disabled" do
        let(:provider_title) { "Community Health Options" }
        let(:setting) { double }

        before :each do
          allow(PolypressRegistry).to receive(:feature_enabled?).with(:modify_carrier_legal_names).and_return(false)
        end

        it "returns provider_title as is" do
          params = { tax_household: tax_household,
                     recipient: recipient,
                     insurance_policy: insurance_policy,
                     insurance_agreement: insurance_agreement,
                     included_hbx_ids: included_hbx_ids }
          irs_yearly_pdf_report = IrsYearlyPdfReport.new(params)
          result = irs_yearly_pdf_report.fetch_insurance_provider_title(provider_title)
          expect(result).to eq("Community Health Options")
        end
      end
    end
  end
end