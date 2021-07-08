# frozen_string_literal: true

# RenderLiquid
class RenderLiquid
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
      return family_hash if params[:key].to_s == 'enrollment_submitted'
      application_hash
    else
      params[:entity].to_h
    end
  end

  def construct_settings(params)
    entity_hash = fetch_entity_hash(params)
    # oe_end_on_year = entity_hash[:oe_start_on].year
    settings_hash = {
      :key => params[:key],
      :notice_number => params[:subject],
      :short_name => Settings.site.short_name,
      :day_45_from_now => Date.today + 45.days,
      :day_95_from_now => Date.today + 95.days,
      :medicaid_agency_name => Settings.notices.individual_market.medicaid.agency_name,
      :medicaid_agency_phone => Settings.notices.individual_market.medicaid.agency_phone,
      :medicaid_chip_long_name => Settings.notices.individual_market.medicaid.chip_long_name,
      :medicaid_chip_short_name => Settings.notices.individual_market.medicaid.chip_short_name,
      :medicaid_program_name => Settings.notices.individual_market.medicaid.program_name,
      :marketplace_phone => Settings.contact_center.short_number,
      :marketplace_url => Settings.site.website_url,
      :marketplace_shopping_name => Settings.notices.individual_market.shopping_name,
      :oe_end_on => Date.new(2021, 12, 15)
    }
    entity_hash.merge(settings_hash)
  end

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
