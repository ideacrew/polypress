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

    it "should set correct calendar_year fetch correct irs_document based on calendr_year" do
      params = { tax_household: tax_household,
                 recipient: recipient,
                 insurance_policy: insurance_policy,
                 insurance_agreement: insurance_agreement,
                 included_hbx_ids: included_hbx_ids }
      irs_yearly_pdf_report = IrsYearlyPdfReport.new(params)
      calender_year = irs_yearly_pdf_report.calender_year
      expect(calender_year).to eq(insurance_agreement[:plan_year].to_i)
      expect(irs_yearly_pdf_report.instance_variable_get(:@document_path)).to eq("#{Rails.root}/lib/pdf_templates/#{calender_year}_1095A_form.pdf")
    end
  end
end