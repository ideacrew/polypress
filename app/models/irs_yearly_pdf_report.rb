# frozen_string_literal: true

# Appends data on to 1095A tax forms
class IrsYearlyPdfReport < PdfReport
  include ActionView::Helpers::NumberHelper
  include ::Config::SiteHelper

  attr_accessor :responsible_party_data, :calender_year

  def initialize(params)
    @tax_household = params[:tax_household]
    @recipient = params[:recipient]
    # indicates which individuals are to be included on this form (5 max per form)
    @included_hbx_ids = params[:included_hbx_ids]
    initialize_variables(params)
    super({ :template => fetch_irs_form_template, :margin => [30, 55] })
    font_size 11
  end

  def address
    if @recipient[:person]
      @recipient[:person][:addresses].detect { |address| address[:kind] == 'mailing' } || @recipient[:person][:addresses][0]
    else
      @recipient[:addresses].detect { |address| address[:kind] == 'mailing' } || @recipient[:addresses][0]
    end
  end

  def initialize_variables(options)
    @insurance_policy = options[:insurance_policy]
    @insurance_agreement = options[:insurance_agreement]
    @spouse = @tax_household[:covered_individuals].detect do |covered_individual|
      covered_individual[:relation_with_primary] == 'spouse'
    end

    @has_spouse_and_not_same_as_recipient = @spouse.present? && (@spouse[:person][:hbx_id] != @recipient[:person][:hbx_id])
    @has_aptc = @tax_household[:months_of_year].any? { |month| month[:coverage_information] && month[:coverage_information][:tax_credit][:cents] > 0 }

    @reporting_year = @calender_year = @insurance_agreement[:plan_year].to_i
    @multiple = options[:multiple]
    @void = (@tax_household[:void]&.to_s == 'true')
    @corrected = (@tax_household[:corrected]&.to_s == 'true')
  end

  def fetch_irs_form_template
    "#{Rails.root}/lib/pdf_templates/#{@reporting_year}_1095A_form.pdf"
  end

  def process
    fill_subscriber_details
    fill_household_details
    fill_premium_details
  end

  def fill_enrollee(enrollee, responsible_party_data = {})
    col1 = mm2pt(-2)
    col3 = mm2pt(102.50)
    col4 = mm2pt(145.50)
    y_pos = cursor

    bounding_box([col1, y_pos], :width => 240) do
      text("#{enrollee[:person][:person_name][:first_name]} #{enrollee[:person][:person_name][:last_name]}".titleize)
    end

    enrollee_ssn = responsible_party_data.blank? ? enrollee[:person][:person_demographics][:encrypted_ssn] : responsible_party_data[0]

    if enrollee_ssn.present?
      bounding_box([col3, y_pos], :width => 100) do
        text mask_ssn(enrollee_ssn)
      end
    else
      enrollee_dob =
        if responsible_party_data.blank?
          enrollee[:person][:person_demographics][:dob].strftime("%m/%d/%Y")
        else
          responsible_party_data[1].strftime("%m/%d/%Y")
        end
      bounding_box([col4, y_pos], :width => 100) do
        text enrollee_dob || ''
      end
    end
  end

  # rubocop:disable Metrics/MethodLength
  def fill_household_details
    col1 = mm2pt(0)
    col2 = mm2pt(67.50)
    col3 = mm2pt(98.50)
    col4 = mm2pt(128.50)
    col5 = mm2pt(159.50)

    y_pos = 472

    covered_individuals = @tax_household[:covered_individuals]
    # covered_household = @notice.covered_household[5..9] if @multiple

    covered_individuals.each do |individual|
      next unless @included_hbx_ids.include?(individual[:person][:hbx_id])

      bounding_box([col1, y_pos], :width => 150) do
        text("#{individual[:person][:person_name][:first_name]} #{individual[:person][:person_name][:last_name]}".titleize)
      end

      individual_demographics = individual[:person][:person_demographics]
      if individual_demographics[:encrypted_ssn].present?
        bounding_box([col2, y_pos], :width => 100) do
          text mask_ssn(individual_demographics[:encrypted_ssn])
        end
      else
        bounding_box([col3, y_pos], :width => 100) do
          text individual_demographics[:dob]&.strftime("%m/%d/%Y")
        end
      end
      bounding_box([col4, y_pos], :width => 100) do
        text individual[:coverage_start_on]&.strftime("%m/%d/%Y")
      end
      bounding_box([col5, y_pos], :width => 100) do
        text individual[:coverage_end_on]&.strftime("%m/%d/%Y")
      end
      y_pos -= 24
    end
  end

  # rubocop:disable Metrics/AbcSize
  def fill_subscriber_details
    col1 = mm2pt(-2)
    col2 = mm2pt(51.50)
    col3 = mm2pt(102.50)
    y_pos = 790.86 - mm2pt(37.15) - 45

    x_pos_corrected = mm2pt(128.50)
    y_pos_corrected = 790.86 - mm2pt(31.80)
    y_pos_corrected = 790.86 - mm2pt(23.80) if @void && @calender_year >= 2015

    if @corrected || @void
      bounding_box([x_pos_corrected, y_pos_corrected], :width => 100) do
        text "x"
      end
    end

    font "Times-Roman"

    bounding_box([col1, y_pos], :width => 100) do
      text site_state_abbreviation
    end

    bounding_box([col2, y_pos], :width => 150) do
      text @insurance_policy[:policy_id]
    end

    bounding_box([col3, y_pos], :width => 250) do
      text(fetch_insurance_provider_title(@insurance_agreement[:insurance_provider][:title]))
    end

    move_down(12)
    raise "no subscriber!!" if @recipient.blank?

    fill_enrollee(@recipient, @responsible_party_data)

    move_down(12)
    if @has_spouse_and_not_same_as_recipient && @has_aptc
      fill_enrollee(@spouse)
    else
      move_down(13)
    end
    move_down(11)
    y_pos = cursor
    bounding_box([col1, y_pos], :width => 100) do
      text @insurance_policy[:start_on]&.strftime("%m/%d/%Y")
    end

    bounding_box([col2, y_pos], :width => 100) do
      text @insurance_policy[:end_on]&.strftime("%m/%d/%Y")
    end

    bounding_box([col3, y_pos], :width => 250) do
      street_address = address[:address_1]
      street_address += ", #{address[:address_2]}" if address[:address_2].present?
      text street_address
    end

    move_down(12)
    y_pos = cursor
    bounding_box([col1, y_pos], :width => 120) do
      text address[:city]
    end

    bounding_box([col2, y_pos], :width => 100) do
      text address[:state]
    end

    bounding_box([col3, y_pos], :width => 100) do
      text address[:zip]
    end
  end
  # rubocop:enable Metrics/AbcSize

  def fetch_insurance_provider_title(title)
    {
      "Anthem Blue Cross and Blue Shield" => "Anthem Health Plans of Maine Inc",
      "Harvard Pilgrim Health Care" => "Harvard Pilgrim Health Care Inc",
      "Community Health Options" => "Maine Community Health Options",
      "Taro Health" => "Taro Health Plan of Maine Inc"
    }[title] || title
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def fill_premium_details
    col1 = mm2pt(36.50)
    col2 = mm2pt(76.50)
    col3 = mm2pt(125.50)
    y_pos = 304

    (1..12).each do |index|
      month = Date::MONTHNAMES[index]

      monthly_premium = @tax_household[:months_of_year].detect { |month_of_year| month_of_year[:month] == month }
      coverage_information = monthly_premium[:coverage_information] if monthly_premium

      if coverage_information
        bounding_box([col1, y_pos], :width => 100) do
          text cents_to_dollars(@catastrophic_corrected ? 0.0 : coverage_information[:total_premium][:cents]), :align => :right
        end

        aptc_amount = coverage_information[:tax_credit][:cents]
        if aptc_amount.present? && aptc_amount.to_f > 0
          bounding_box([col2, y_pos], :width => 130) do
            text cents_to_dollars(@catastrophic_corrected ? 0.0 : coverage_information[:slcsp_benchmark_premium][:cents]), :align => :right
          end

          bounding_box([col3, y_pos], :width => 120) do
            text cents_to_dollars(aptc_amount), :align => :right
          end
        end
      end
      y_pos -= 24
    end

    annual_premiums = @tax_household[:annual_premiums]
    bounding_box([col1, y_pos], :width => 100) do
      text cents_to_dollars(@catastrophic_corrected ? 0.0 : annual_premiums[:total_premium][:cents]), :align => :right
    end

    annual_aptc_amount = annual_premiums[:tax_credit][:cents]
    return unless annual_aptc_amount.present? && annual_aptc_amount.to_f > 0

    bounding_box([col2, y_pos], :width => 130) do
      text cents_to_dollars(@catastrophic_corrected ? 0.0 : annual_premiums[:slcsp_benchmark_premium][:cents]), :align => :right
    end

    bounding_box([col3, y_pos], :width => 120) do
      text cents_to_dollars(annual_aptc_amount), :align => :right
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength

  def decrypt_ssn(encrypted_ssn)
    AcaEntities::Operations::Encryption::Decrypt.new.call({ value: encrypted_ssn }).value!
  end

  def mask_ssn(encrypted_ssn)
    return if encrypted_ssn.blank?
    ssn = decrypt_ssn(encrypted_ssn)
    last_digits = ssn.match(/\d{4}$/)[0]
    "***-**-#{last_digits}"
  end
end
