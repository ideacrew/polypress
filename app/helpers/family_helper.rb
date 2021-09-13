# frozen_string_literal: true

# FamilyHelper
module FamilyHelper
  # TODO: dynamically load data using contracts/entities
  def verification_types(type, date)
    [
      {
        :type_name => type,
        :validation_status => "outstanding",
        :due_date => date
      }
    ]
  end

  def family_hash
    {
      :documents_needed => true,
      :hbx_id => '43456',
      :family_members => [family_member_2, family_member_1],
      :households => households
    }
  end

  def family_member_1
    {
      :is_primary_applicant => true,
      :person => {
        :hbx_id => "475",
        :person_name => { :first_name => "John", :last_name => "Smith1" },
        :person_demographics => {
          :ssn => "784796992",
          :gender => "male",
          :dob => Date.new(1972, 4, 4),
          :is_incarcerated => false
        },
        :person_health => { :is_tobacco_user => "unknown" },
        :is_active => true,
        :is_disabled => false,
        :addresses => [{ :kind => 'mailing', :address_1 => 'H st', :state => "ME", :city => 'Augusta', :zip => '67662' }],
        :verification_types => verification_types('Social Security Number', Date.today + 40.days)
      }
    }
  end

  def family_member_2
    {
      :is_primary_applicant => false,
      :person => {
        :hbx_id => "476",
        :person_name => { :first_name => "John", :last_name => "Smith2" },
        :person_demographics => {
          :ssn => "784796993",
          :gender => "male",
          :dob => Date.new(1978, 4, 4),
          :is_incarcerated => false
        },
        :person_health => { :is_tobacco_user => "unknown" },
        :is_active => true,
        :is_disabled => false,
        :addresses => [{ :kind => 'mailing', :address_1 => 'H st', :state => "ME", :city => 'Augusta', :zip => '67662' }],
        :verification_types => verification_types('American Indian Status', Date.today)
      }
    }
  end

  def households
    [
      {
        :start_date => Date.today,
        :is_active => true,
        :irs_group_reference => {},
        :coverage_households => [
          {
            :is_immediate_family => true,
            :coverage_household_members => [{ :is_subscriber => true }]
          },
          {
            :is_immediate_family => false,
            :coverage_household_members => []
          }
        ],
        :hbx_enrollments => hbx_enrollments
      }
    ]
  end

  def hbx_enrollments
    [
      {
        :is_receiving_assistance => true,
        :effective_on => Date.today,
        :aasm_state => "coverage_selected",
        :applied_aptc_amount => { cents: BigDecimal(44_500), currency_iso: 'USD' },
        :market_place_kind => "individual",
        :total_premium => 445.09,
        :enrollment_period_kind => "open_enrollment",
        :product_kind => "health",
        :hbx_enrollment_members => [
          hbx_enrollment_member('1', 'Smith1', "475", 45, true),
          hbx_enrollment_member('2', 'Smith2', "476", 46, false)
        ],
        :product_reference => product_reference,
        :issuer_profile_reference => issuer_profile_reference,
        :consumer_role_reference => consumer_role_preference
      }
    ]
  end

  def hbx_enrollment_member(id, l_name, hbx_id, age, subs)
    {
      :family_member_reference => {
        :family_member_hbx_id => id,
        :first_name => "John",
        :last_name => l_name,
        :person_hbx_id => hbx_id,
        :age => age
      },
      :is_subscriber => subs,
      :eligibility_date => Date.today,
      :coverage_start_on => Date.today
    }
  end

  def product_reference
    {
      :is_csr => true,
      :individual_deductible => "700",
      :family_deductible => "1400",
      :hios_id => "41842DC0400010-01",
      :name => "BlueChoice silver1 2,000",
      :active_year => 2021,
      :is_dental_only => false,
      :metal_level => "silver",
      :benefit_market_kind => "aca_individual",
      :product_kind => "health",
      :issuer_profile_reference => issuer_profile_reference
    }
  end

  def issuer_profile_reference
    {
      :phone => "7869087789",
      :hbx_id => "bb35d006bd844d4c91b68983569dc676",
      :name => "Blue Cross Blue Shield",
      :abbrev => "ANTHM"
    }
  end

  def  consumer_role_preference
    {
      :is_active => true,
      :is_applying_coverage => true,
      :is_applicant => true,
      :is_state_resident => true,
      :lawful_presence_determination => {},
      :citizen_status => "us_citizen"
    }
  end
end
