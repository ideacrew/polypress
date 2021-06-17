# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MagiMedicaid::PublishUqhpEligibleDocument do
  describe 'with valid arguments' do

    let(:current_date) { Date.today }
    let(:member_dob) { Date.new(current_date.year - 22, current_date.month, current_date.day) }
    let(:aptc_effective_date) { Date.today.next_month.beginning_of_month }
    let(:application_hash) do
      {
        :family_reference => { :hbx_id => "10011" },
        :assistance_year => current_date.year,
        :aptc_effective_date => aptc_effective_date,
        :applicants => [{ :name => { :first_name => "Gerald", :last_name => "Rivers" },
                          :identifying_information => { :has_ssn => false },
                          :demographic => { :gender => "Male",
                                            :dob => member_dob,
                                            :is_veteran_or_active_military => false },
                          :attestation => { :is_incarcerated => false,
                                            :is_self_attested_disabled => true,
                                            :is_self_attested_blind => false },
                          :is_primary_applicant => true,
                          :native_american_information => { :indian_tribe_member => false },
                          :citizenship_immigration_status_information => { :citizen_status => "us_citizen",
                                                                           :is_lawful_presence_self_attested => false },
                          :is_applying_coverage => true,
                          :family_member_reference => { :family_member_hbx_id => "1000",
                                                        :first_name => "Gerald",
                                                        :last_name => "Rivers",
                                                        :person_hbx_id => "95",
                                                        :is_primary_family_member => true },
                          :person_hbx_id => "95",
                          :is_required_to_file_taxes => true,
                          :tax_filer_kind => "tax_filer",
                          :is_joint_tax_filing => true,
                          :is_claimed_as_tax_dependent => false,
                          :claimed_as_tax_dependent_by => nil,
                          :student => { :is_student => false },
                          :is_refugee => false,
                          :is_trafficking_victim => false,
                          :foster_care => { :is_former_foster_care => false },
                          :pregnancy_information => { :is_pregnant => false,
                                                      :is_post_partum_period => false,
                                                      :expected_children_count => nil },
                          :is_subject_to_five_year_bar => false,
                          :is_five_year_bar_met => false,
                          :has_job_income => true,
                          :has_self_employment_income => false,
                          :has_unemployment_income => false,
                          :has_other_income => false,
                          :has_deductions => false,
                          :has_enrolled_health_coverage => false,
                          :has_eligible_health_coverage => false,
                          :medicaid_and_chip => { :not_eligible_in_last_90_days => true,
                                                  :denied_on => Date.today },
                          :addresses => [{ :has_fixed_address => true,
                                           :kind => "home",
                                           :address_1 => "1234",
                                           :address_3 => "person",
                                           :city => "test",
                                           :county => nil,
                                           :state => "DC",
                                           :zip => "12345",
                                           :country_name => "USA",
                                           :validation_status => "ValidMatch",
                                           :start_on => aptc_effective_date,
                                           :end_on => nil,
                                           :lives_outside_state_temporarily => false }],
                          :incomes => [{ :kind => "wages_and_salaries",
                                         :amount => 16_500.00,
                                         :frequency_kind => "Annually",
                                         :start_on => Date.today.beginning_of_year }],
                          :is_medicare_eligible => false,
                          :has_insurance => false,
                          :has_state_health_benefit => false,
                          :had_prior_insurance => false,
                          :age_of_applicant => 22,
                          :is_self_attested_long_term_care => false,
                          :hours_worked_per_week => 0,
                          :is_temporarily_out_of_state => false,
                          :is_claimed_as_dependent_by_non_applicant => false,
                          :benchmark_premium =>
                            { :health_only_lcsp_premiums => [{ :member_identifier => "95", :monthly_premium => 430.48 }],
                              :health_only_slcsp_premiums => [{ :member_identifier => "95", :monthly_premium => 496.23 }] },
                          :is_homeless => false,
                          :mitc_income =>
                            { :amount => 14_976,
                              :taxable_interest => 0,
                              :tax_exempt_interest => 0,
                              :taxable_refunds => 0,
                              :alimony => 0,
                              :capital_gain_or_loss => 0,
                              :pensions_and_annuities_taxable_amount => 0,
                              :farm_income_or_loss => 0,
                              :unemployment_compensation => 0,
                              :other_income => 0,
                              :magi_deductions => 0,
                              :adjusted_gross_income => 0,
                              :deductible_part_of_self_employment_tax => 0,
                              :ira_deduction => 0,
                              :student_loan_interest_deduction => 0,
                              :tution_and_fees => 0,
                              :other_magi_eligible_income => 0 },
                          :mitc_relationships => [] }],
        :tax_households => [{ :max_aptc => 496.0,
                              effective_on: Date.today.next_month.beginning_of_month,
                              determined_on: Date.today,
                              annual_tax_household_income: 16_000.0,
                              csr_annual_income_limit: 142_912_000.0,
                              :hbx_id => "12345",
                              :is_insurance_assistance_eligible => "Yes",
                              :tax_household_members => [{
                                :product_eligibility_determination => { :is_ia_eligible => true,
                                                                        :is_medicaid_chip_eligible => false,
                                                                        :is_totally_ineligible => nil,
                                                                        :is_magi_medicaid => false,
                                                                        :is_uqhp_eligible => nil,
                                                                        :is_csr_eligible => true,
                                                                        :csr => "94",
                                                                        :is_non_magi_medicaid_eligible => false,
                                                                        :is_without_assistance => false },
                                :applicant_reference => { :first_name => "Gerald",
                                                          :last_name => "Rivers",
                                                          :dob => member_dob,
                                                          :person_hbx_id => "95" }
                              }] }],
        :relationships => [],
        :us_state => "DC",
        :hbx_id => "200000126",
        :oe_start_on => Date.new(current_date.year, 11, 1),
        :mitc_households => [{ :household_id => "1", :people => [{ :person_id => 95 }] }],
        :mitc_tax_returns => [{ :filers => [{ :person_id => 95 }], :dependents => [] }]
      }
    end

    let(:title) { 'Uqhp Document' }
    let(:event_key) { 'magi_medicaid.determined_uqhp_eligible' }
    let(:body) { '<p>Uqhp Eligible Document for {{ hbx_id }}</p>' }
    let(:template_subject) { 'Uqhp Subject' }

    let!(:template) do
      FactoryBot.create(
        :template,
        key: event_key,
        body: body,
        title: title,
        subject: template_subject,
        category: 'aca_individual',
        recipient: 'AcaEntities::Families::Family',
        content_type: 'application/pdf',
        description: 'Uqhp Descriptoin'
      )
    end

    subject do
      described_class.new.call(application: application_hash, event_key: event_key)
    end

    context "when payload has all the required params" do
      it 'should return success' do
        expect(subject.success?).to be_truthy
      end
    end

    context "when event key is missing" do
      let(:event_key) { nil }

      let(:error) { "Missing event key for resource_id: #{application_hash[:family_reference][:hbx_id]}" }

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure).to eq error
      end
    end

    context "when event key is invalid" do
      let(:invalid_subject) { described_class.new.call(application: application_hash, event_key: invalid_event_key) }

      let(:invalid_event_key) { 'invalid_event_key' }

      let(:error) { "No template found for the given #{invalid_event_key} & for resource #{application_hash[:family_reference][:hbx_id]}" }

      it 'should return failure' do
        expect(invalid_subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(invalid_subject.failure).to eq error
      end
    end

    context "when template body has unknown attributes" do
      let(:body) { '<p>Uqhp Eligible Document for {{ unknown_attribute }}</p><p> {{ unknown_attribute_new }} </p> ' }

      let(:error) do
        ["Liquid error (line 1): undefined variable unknown_attribute", "Liquid error (line 1): undefined variable unknown_attribute_new"]
      end

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure.map(&:to_s)).to eq error
      end
    end

    context "when template body has syntax errors" do
      let(:body) { '<p>Uqhp Eligible Document for {% if %}</p>' }

      let(:error) { "Liquid syntax error (line 1): Syntax Error in tag 'if' - Valid syntax: if [expression]" }

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure.to_s).to eq error
      end
    end

    context "when input application hash is invalid" do
      let(:error) { '[#<Dry::Schema::Message text="is missing" path=[:family_reference, :hbx_id] predicate=:key? input={}>]' }

      before { application_hash[:family_reference].delete(:hbx_id) }

      it 'should return failure' do
        expect(subject.failure?).to be_truthy
      end

      it 'should return errors' do
        expect(subject.failure.errors.messages.to_s).to eq error
      end
    end
  end
end
