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

     it "set spouse details" do
      params = { tax_household: tax_household,
                 recipient: recipient,
                 insurance_policy: insurance_policy,
                 insurance_agreement: insurance_agreement,
                 included_hbx_ids: included_hbx_ids }
      irs_yearly_pdf_report = IrsYearlyPdfReport.new(params)
      expect(irs_yearly_pdf_report.instance_variable_get(:@spouse)).to be_present
      spouse_details = irs_yearly_pdf_report.instance_variable_get(:@spouse)
      expect(spouse_details.dig(:family_member_reference, :first_name)).to be_present
       
    context "#fetch_insurance_provider_title" do
      context "when insurance_provider is Community health options" do
        let(:provider_title) { "Community Health Options" }
        it "returns correct title for insurance_provider" do
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
    end
  end
end