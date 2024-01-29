# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
# FamilyHelper
module FamilyHelper
  include FinancialApplicationHelper

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
      :hbx_id => '2200000001000533',
      :family_members => [family_member_2, family_member_1],
      :households => households,
      :min_verification_due_date => current_date,
      :magi_medicaid_applications => [application_hash]
    }
  end

  def insurance_provider
    {
      hios_id: '98765432',
      title: 'MAINE COMMUNITY HEALTH OPTIONS',
      fein: "12345",
      insurance_products: [
        {
          name: "ABC plan",
          hios_plan_id: "123456",
          plan_year: 2023,
          coverage_type: "health",
          metal_level: "silver",
          market_type: "individual",
          ehb: "1.0"
        }
      ]

    }
  end

  def contract_holder
    {
      member_id: '1055668',
      hbx_id: "1009522",
      insurer_assigned_id: 'HP597762000',
      person_name: {
        last_name: 'John',
        first_name: 'Smith1'
      },
      dob: current_date - 50.years,
      gender: "male",
      addresses: [
        {
          kind: "home",
          address_1: "S Street NW",
          address_2: "",
          address_3: "",
          city: "Awesome city",
          county_name: "Awesome county",
          state_abbreviation: "DC",
          zip_code: "20002"
        }
      ]
    }
  end

  def insurance_agreements
    [
      {
        plan_year: current_date.year,
        start_on: current_date.beginning_of_year,
        contract_holder: contract_holder,
        insurance_provider: insurance_provider,
        insurance_policies: [insurance_policy]
      }
    ]
  end

  def currency
    {
      cents: 98_700.0,
      currency_iso: "USD"
    }
  end

  def insurance_product
    {
      name: 'Insurer Coverall Health Product',
      hios_plan_id: "123456",
      plan_year: 2023,
      coverage_type: "health",
      metal_level: "silver",
      market_type: "individual",
      ehb: "1.0",
      insurance_product_features: [
        {
          key: 'pediatric_dental',
          title: 'Pediatric Dental Coverage',
          description: 'Plan includes dental essential benefits for all enrollees under age 19',
          value: 100.0
        }
      ]
    }
  end

  def enrolled_member
    {
      enrolled_member: {
        member: {
          hbx_id: '1009522',
          member_id: '1055668',
          insurer_assigned_id: 'HP597762000',
          person_name: { :first_name => "John", :last_name => "Smith1" },
          relationship_code: '1:18',
          dob: Date.new(1972, 4, 4),
          gender: 'male',
          addresses: addresses,
          phones: phones,
          emails: [{ kind: 'home', address: 'george.jetson@example.com' }]
        },
        enrolled_member_premium: {
          insurance_rate: 575.23,
          premium_schedule: premium_schedule
        },
        primary_care_provider: primary_care_provider,
        is_tobacco_user: true
      }
    }
  end

  def enrolled_dependent
    {
      enrolled_member: {
        member: {
          hbx_id: '1009523',
          member_id: '1055678',
          insurer_assigned_id: 'HP597762002',
          person_name: {
            last_name: 'Rosy',
            first_name: 'Smith'
          },
          relationship_code: '4:19',
          dob: Date.new(1983, 9, 6),
          gender: 'female',
          addresses: person_addresses
        },
        enrolled_member_premium: {
          insurance_rate: 615.88,
          premium_schedule: premium_schedule
        },
        primary_care_provider: primary_care_provider,
        is_tobacco_user: false
      }
    }
  end

  def primary_care_provider
    { name: { first_name: 'Florence', last_name: 'Nightengale' } }
  end

  def premium_schedule
    {
      premium_amount: 345.66,
      insured_start_on: january_1,
      insured_end_on: december_31,
      valid_start_on: january_1,
      valid_end_on: december_31
    }
  end

  def enrolled_subscriber
    enrolled_member[:enrolled_member]
  end

  def enrolled_dependents
    [enrolled_dependent[:enrolled_member]]
  end

  def insurance_policy_enrollments
    [
      {
        start_on: "2023-01-01",
        subscriber: {
          member: {
            hbx_id: "1000595",
            member_id: "1000595",
            person_name: person_name
          },
          dob: "",
          gender: "male",
          addresses: person_addresses,
          emails: [{ kind: "home", address: "test@gmail.com" }]
        },
        dependents: [],
        total_premium_amount: { cents: 50_000, currency_iso: "USD" },
        tax_households: ip_tax_households,
        total_premium_adjustment_amount: { cents: 5_000, currency_iso: "USD" }
      }
    ]
  end

  def ip_tax_households
    [
      {
        hbx_id: "828762",
        tax_household_members: tax_household_members
      }
    ]
  end

  def tax_household_members
    [
      {
        family_member_reference: {
          family_member_hbx_id: "1000595",
          relation_with_primary: "self"
        },
        tax_filer_status: "tax_filer",
        is_subscriber: true
      }
    ]
  end

  def person_name
    {
      first_name: 'John',
      middle_name: 'Austin',
      last_name: 'Smith1'
    }
  end

  def person_health
    {
      is_tobacco_user: 'unknown',
      is_physically_disabled: false
    }
  end

  def person_demographics
    {
      ssn: "123456789",
      no_ssn: false,
      gender: 'male',
      dob: Date.today,
      is_incarcerated: false
    }
  end

  def person_reference
    {
      hbx_id: '1234',
      first_name: 'John',
      middle_name: 'Austin',
      last_name: 'Smith1',
      dob: Date.today,
      gender: 'male',
      ssn: nil
    }
  end

  def person_addresses
    [
      {
        kind: "home",
        address_1: "S Street NW",
        address_2: "",
        address_3: "",
        city: "City",
        county: "",
        state: "ST",
        location_state_code: nil,
        full_text: nil,
        zip: "20009",
        country_name: ""
      }
    ]
  end

  def person
    {
      hbx_id: '1009522',
      is_active: true,
      is_disabled: false,
      no_dc_address: nil,
      no_dc_address_reason: nil,
      is_homeless: nil,
      is_temporarily_out_of_state: nil,
      age_off_excluded: nil,
      is_applying_for_assistance: nil,
      person_name: person_name,
      person_health: person_health,
      person_demographics: person_demographics,
      person_relationships: [],
      addresses: person_addresses,
      phones: phones,
      emails: emails
    }
  end

  def phones
    [{ kind: 'mobile', primary: true, area_code: '208', number: '5551212', start_on: current_date }]
  end

  def emails
    [
      {
        kind: "home",
        address: "john.smith1@example.com"
      }
    ]
  end

  def january_1
    current_date.beginning_of_year
  end

  def december_31
    current_date.end_of_year
  end

  def covered_individual
    {
      coverage_start_on: january_1,
      coverage_end_on: december_31,
      person: person,
      filer_status: "tax_filer",
      relation_with_primary: "self"
    }
  end

  def coverage_information
    {
      tax_credit: currency,
      total_premium: currency,
      slcsp_benchmark_premium: currency
    }
  end

  def months_of_year
    [
      {
        month: "April",
        coverage_information: {
          tax_credit: { cents: 5_000, currency_iso: "USD" },
          total_premium: { cents: 50_000, currency_iso: "USD" },
          slcsp_benchmark_premium: { cents: 50_000, currency_iso: "USD" }
        }
      },
      {
        month: "August",
        coverage_information: {
          tax_credit: { cents: 5_000, currency_iso: "USD" },
          total_premium: { cents: 50_000, currency_iso: "USD" },
          slcsp_benchmark_premium: { cents: 50_000, currency_iso: "USD" }
        }
      }
    ]
  end

  def covered_individuals
    [
      {
        coverage_start_on: "2023-01-01",
        coverage_end_on: "2023-12-31",
        person: {
          hbx_id: "1000595",
          person_name: person_name,
          person_demographics: person_demographics,
          person_health: {},
          is_active: true,
          addresses: person_addresses,
          emails: [{ kind: "home", address: "test@gmail.com" }]
        },
        relation_with_primary: "self",
        filer_status: "tax_filer"
      }
    ]
  end

  def aptc_csr_tax_households
    [
      {
        covered_individuals: covered_individuals,
        tax_household_members: tax_household_members,
        corrected: false,
        void: true,
        months_of_year: months_of_year,
        annual_premiums: annual_premiums
      }
    ]
  end

  def annual_premiums
    {
      tax_credit: {
        cents: 60_000,
        currency_iso: "USD"
      },
      total_premium: {
        cents: 600_000,
        currency_iso: "USD"
      },
      slcsp_benchmark_premium: {
        cents: 600_000,
        currency_iso: "USD"
      }
    }
  end

  def insurance_policy
    {
      policy_id: "1197899",
      insurance_product: insurance_product,
      enrollments: insurance_policy_enrollments,
      aptc_csr_tax_households: aptc_csr_tax_households,
      hbx_enrollment_ids: ["1234567"],
      start_on: january_1,
      end_on: december_31
    }
  end

  def family_member_1
    {
      :is_primary_applicant => true,
      :person => {
        :hbx_id => "1009522",
        :person_name => { :first_name => "John", :last_name => "Smith1" },
        :person_demographics => {
          :ssn => "784796992",
          :gender => "male",
          :dob => Date.new(1972, 4, 4),
          :is_incarcerated => false
        },
        :consumer_role => consumer_role(true),
        :person_health => { :is_tobacco_user => "unknown" },
        :is_active => true,
        :is_disabled => false,
        :addresses => person_addresses,
        :verification_types => verification_types('Social Security Number', current_date + 40.days)
      }
    }
  end

  def family_member_2
    {
      :is_primary_applicant => false,
      :person => {
        :hbx_id => "1009523",
        :person_name => { :first_name => "John", :last_name => "Smith2" },
        :person_demographics => {
          :ssn => "784796993",
          :gender => "male",
          :dob => Date.new(1978, 4, 4),
          :is_incarcerated => false
        },
        :consumer_role => consumer_role(false),
        :person_health => { :is_tobacco_user => "unknown" },
        :is_active => true,
        :is_disabled => false,
        :addresses => [{ :kind => 'mailing', :address_1 => 'H st', :state => "ME", :city => 'Augusta', :zip => '67662' }],
        :verification_types => verification_types('American Indian Status', current_date)
      }
    }
  end

  def consumer_role(indicator)
    {
      is_applying_coverage: indicator,
      five_year_bar: false,
      requested_coverage_start_date: Date.new(2021, 1, 1),
      aasm_state: 'fully_verified',
      is_applicant: true,
      is_state_resident: true,
      identity_validation: 'na',
      identity_update_reason: 'na',
      application_validation: 'na',
      application_update_reason: 'na',
      identity_rejected: false,
      application_rejected: false,
      lawful_presence_determination: {}
    }
  end

  def households
    [
      {
        :start_date => current_date,
        :is_active => true,
        :irs_group_reference => {},
        :coverage_households => [
          {
            :is_immediate_family => true,
            :coverage_household_members => [{ :is_subscriber => true }]
          },
          {
            :is_immediate_family => false,
            :coverage_household_members => [{ :is_subscriber => false }]
          }
        ],
        :hbx_enrollments => hbx_enrollments,
        :insurance_agreements => insurance_agreements
      }
    ]
  end

  def health_enrollment
    {
      :is_receiving_assistance => true,
      :effective_on => current_date,
      :aasm_state => "auto_renewing",
      :applied_aptc_amount => { cents: BigDecimal(44_500), currency_iso: 'USD' },
      :market_place_kind => "individual",
      :total_premium => 445.09,
      :enrollment_period_kind => "open_enrollment",
      :product_kind => "health",
      :hbx_enrollment_members => [
        hbx_enrollment_member('1', 'Smith1', "1009522", 45, true),
        hbx_enrollment_member('2', 'Smith2', "1009523", 46, false)
      ],
      :product_reference => product_reference(false),
      :issuer_profile_reference => issuer_profile_reference,
      :consumer_role_reference => consumer_role_preference,
      :timestamp => {
        submitted_at: current_date.to_datetime,
        created_at: current_date.to_datetime,
        modified_at: current_date.to_datetime
      }
    }
  end

  def dental_enrollment
    {
      :effective_on => current_date,
      :aasm_state => "auto_renewing",
      :applied_aptc_amount => { cents: BigDecimal(0), currency_iso: 'USD' },
      :market_place_kind => "individual",
      :total_premium => 645.09,
      :enrollment_period_kind => "open_enrollment",
      :product_kind => "dental",
      :hbx_enrollment_members => [
        hbx_enrollment_member('1', 'Smith1', "1009522", 45, true),
        hbx_enrollment_member('2', 'Smith2', "1009523", 46, false)
      ],
      :product_reference => product_reference(false),
      :issuer_profile_reference => issuer_profile_reference,
      :consumer_role_reference => consumer_role_preference,
      :timestamp => {
        submitted_at: current_date.to_datetime,
        created_at: current_date.to_datetime,
        modified_at: current_date.to_datetime
      }
    }
  end

  def hbx_enrollments
    [health_enrollment, dental_enrollment]
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
      :eligibility_date => current_date,
      :coverage_start_on => current_date
    }
  end

  def product_reference(csr)
    {
      :is_csr => csr,
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
      :phone => "(786) 908-7789",
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
# rubocop:enable Metrics/ModuleLength
