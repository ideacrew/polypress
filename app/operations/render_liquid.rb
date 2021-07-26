# frozen_string_literal: true

# RenderLiquid
class RenderLiquid
  send(:include, Config::SiteHelper)
  send(:include, FinancialApplicationHelper)
  send(:include, FamilyHelper)
  send(:include, Dry::Monads[:result, :do])

  # @param [String] :body
  # @param [String] :subject MPI indicator for a given notice
  # @param [Array<Dry::Struct>] :entities
  # @param [Hash] :options
  # @return [Dry::Monads::Result] Parsed template as string
  def call(params)
    parsed_cover_page = yield parse_cover_page if params[:cover_page]
    parsed_body = yield parse_body(params)
    template = yield render(parsed_body, parsed_cover_page, params)

    Success(template)
  end

  private

  def parse_cover_page
    cover_page_content = ApplicationController.new.render_to_string(template: 'templates/ivl_template', layout: false).to_str
    cover_page = Liquid::Template.parse(cover_page_content, line_numbers: true)
    Success(cover_page)
  rescue StandardError => e
    Failure(e)
  end

  def parse_body(params)
    body = params[:body] || params[:template].body
    template = Liquid::Template.parse(body, line_numbers: true)
    Success(template)
  rescue StandardError => e
    Failure(e)
  end

  def fetch_entity_hash(params)
    if params[:instant_preview] || params[:preview]
      return family_hash if ['enrollment_submitted', '1_outstanding_verifications_insert'].include?(params[:key].to_s)
      application_hash
    else
      params[:entity].to_h
    end
  end

  def recipient_name_and_address(params)
    mailing_address = nil
    recipient_name =
      if params[:applicants]
        applicant = params[:applicants].detect { |app| app[:is_primary_applicant] } || params[:applicants][0]
        mailing_address = applicant[:addresses][0]
        applicant[:name]
      else
        applicant = params[:family_members].detect { |app| app[:is_primary_applicant] } || params[:family_members][0]
        mailing_address = applicant[:person][:addresses][0]
        applicant[:person][:person_name]
      end
    ["#{recipient_name[:first_name].titleize} #{recipient_name[:last_name].titleize}", mailing_address]
  end

  # rubocop:disable Metrics/AbcSize
  def construct_settings(params)
    entity_hash = fetch_entity_hash(params)
    # oe_end_on_year = entity_hash[:oe_start_on].year
    settings_hash = {
      :mailing_address => recipient_name_and_address(entity_hash)[1],
      :recipient_full_name => recipient_name_and_address(entity_hash)[0],
      :key => params[:key],
      :notice_number => params[:subject],
      :short_name => site_short_name,
      :day_45_from_now => Date.today + 45.days,
      :day_95_from_now => Date.today + 95.days,
      :medicaid_agency_name => medicaid_agency_name,
      :medicaid_agency_phone => medicaid_agency_phone,
      :medicaid_chip_long_name => medicaid_agency_chip_long_name,
      :medicaid_chip_short_name => medicaid_agency_chip_short_name,
      :medicaid_program_name => medicaid_agency_program_name,
      :marketplace_phone => contact_center_short_phone_number,
      :contact_center_state_and_city => contact_center_state_and_city,
      :contact_center_zip_code => contact_center_zip_code,
      :contact_center_po_box => site_po_box,
      :marketplace_url => site_website_url,
      :home_url => site_home_url,
      :marketplace_shopping_name => marketplace_shopping_name,
      :oe_end_on => Date.new(2021, 12, 15)
    }
    entity_hash.merge(settings_hash)
  end
  # rubocop:enable Metrics/AbcSize

  def render(body, cover_page, params)
    entity = construct_settings(params)
    rendered_body = body.render(entity&.deep_stringify_keys, { strict_variables: true })
    document_body =
      if cover_page
        rendered_cover_page = cover_page.render(entity&.deep_stringify_keys, { strict_variables: true })
        rendered_cover_page + rendered_body
      else
        rendered_body
      end
    template = ApplicationController.new.render_to_string(inline: document_body, layout: 'layouts/ivl_pdf_layout')

    return Failure(body.errors) if body.errors.present?

    Success({ rendered_template: template, entity: entity })
  end
end
