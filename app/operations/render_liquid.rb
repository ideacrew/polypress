# frozen_string_literal: true

require 'ostruct'
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

  def recipient(params)
    recipient_name, mailing_address, hbx_id =
      if params[:applicants]
        applicant = params[:applicants].detect { |app| app[:is_primary_applicant] } || params[:applicants][0]
        [applicant[:name], applicant[:addresses][0], applicant[:person_hbx_id]]
      else
        applicant = params[:family_members].detect { |app| app[:is_primary_applicant] } || params[:family_members][0]
        [applicant[:person][:person_name], applicant[:person][:addresses][0], applicant[:person][:hbx_id]]
      end
    recipient_full_name = "#{recipient_name[:first_name].titleize} #{recipient_name[:last_name].titleize}"

    OpenStruct.new(full_name: recipient_full_name, mailing_address: mailing_address, hbx_id: hbx_id)
  end

  def site_settings
    Config::SiteHelper.instance_methods(false).sort.each_with_object({}) do |method, settings_hash|
      begin
        settings_hash[method] = self.send(method)
      rescue StandardError => e
        Rails.logger.error { "Undefined setting #{method} due to #{e.inspect}" }
      end
      settings_hash
    end
  end

  # rubocop:disable Metrics/AbcSize
  def construct_defaults(params)
    entity_hash = fetch_entity_hash(params)
    # oe_end_on_year = entity_hash[:oe_start_on].year
    settings_hash = {
      :mailing_address => recipient(entity_hash).mailing_address,
      :recipient_full_name => recipient(entity_hash).full_name,
      :primary_hbx_id => recipient(entity_hash).hbx_id,
      :key => params[:key],
      :notice_number => params[:subject],
      :day_45_from_now => Date.today + 45.days,
      :day_95_from_now => Date.today + 95.days,
      :oe_end_on => Date.new(2021, 12, 15)
    }.merge(site_settings)
    entity_hash.merge(settings_hash)
  end
  # rubocop:enable Metrics/AbcSize

  def render(body, cover_page, params)
    entity = construct_defaults(params)
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
