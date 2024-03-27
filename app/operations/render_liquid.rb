# frozen_string_literal: true

# rubocop:disable Layout/MultilineMethodCallIndentation
# rubocop:disable Layout/MultilineOperationIndentation

# Renders a Liquid template to HTML using an entity and its properties as the
# data.
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
    # parsed_cover_page = yield parse_cover_page if params[:cover_page]
    # parsed_body = yield parse_body(params)

    cover_page = yield render_cover_page(params)
    body = yield render_body(params)
    document = yield render_document(cover_page, body, params)

    # document = yield render(parsed_body, parsed_cover_page, params)

    Success(document)
  end

  private

  def sanitize_values(entity_hash)
    return nil if entity_hash.blank?

    result = entity_hash.deep_stringify_keys
    result.deep_transform_values do |value|
      value.is_a?(String) ? ActionController::Base.helpers.sanitize(value) : value
    end
  end

  def render_cover_page(params)
    return Success(String.new) if params[:section_preview]

    entity = construct_defaults(params)
    markup =
      ApplicationController
        .new
        .render_to_string(template: 'templates/ivl_template', layout: false)
        .to_str
    template =
      Templates::Template.new(
        {
          title: 'coverpage',
          key: 'coverpage',
          marketplace: 'aca_individual',
          body: {
            markup: markup
          }
        }
      )

    Templates::Render.new.call(
      template: template,
      attributes: sanitize_values(entity)
    )
  end

  def render_body(params)
    entity = construct_defaults(params)
    Templates::Render.new.call(
      template: params[:template],
      attributes: sanitize_values(entity)
    )
  end

  def render_document(cover_page, body, params)
    entity = construct_defaults(params)
    document_body = cover_page + body
    template =
      ApplicationController.new.render_to_string(
        inline: document_body,
        layout: 'layouts/ivl_pdf_layout'
      )

    Success({ rendered_template: template, entity: sanitize_values(entity) })
  end

  def parse_cover_page
    cover_page_content =
      ApplicationController
        .new
        .render_to_string(template: 'templates/ivl_template', layout: false)
        .to_str
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
    return params[:entity].to_h unless params[:instant_preview] || params[:preview]

    if params[:template].recipient.to_s == '::AcaEntities::Families::Family'
      family_hash
    else
      application_hash
    end
  end

  def recipient_name_and_address(params)
    mailing_address = nil
    recipient_name =
      if params[:applicants]
        applicant =
          params[:applicants].detect { |app| app[:is_primary_applicant] } ||
            params[:applicants][0]
        mailing_address = applicant[:addresses].detect { |address| address[:kind] == 'mailing' } || applicant[:addresses][0]
        applicant[:name]
      else
        applicant =
          params[:family_members].detect { |app| app[:is_primary_applicant] } ||
            params[:family_members][0]
        mailing_address = applicant[:person][:addresses].detect { |address| address[:kind] == 'mailing' } ||
          applicant[:person][:addresses]&.send(:[], 0)
        applicant[:person][:person_name]
      end
    [
      "#{recipient_name[:first_name].titleize} #{recipient_name[:last_name].titleize}",
      mailing_address
    ]
  end

  def site_settings
    Config::SiteHelper
      .instance_methods(false)
      .sort
      .each_with_object({}) do |method, settings_hash|
        begin
          settings_hash[method] = self.send(method)
        rescue StandardError => e
          Rails.logger.error do
            "Undefined setting #{method} due to #{e.inspect}"
          end
        end
        settings_hash
      end
  end

  def construct_defaults(params)
    entity_hash = fetch_entity_hash(params)

    # oe_end_on_year = entity_hash[:oe_start_on].year
    settings_hash =
      {
        mailing_address: recipient_name_and_address(entity_hash)[1],
        recipient_full_name: recipient_name_and_address(entity_hash)[0],
        key: params[:key],
        notice_number: params[:subject],
        day_45_from_now: Date.today + 45.days,
        day_95_from_now: Date.today + 95.days,
        oe_end_on: Date.new(2022, 1, 15)
      }.merge(site_settings)
    entity_hash.merge(settings_hash)
  end

  def render(body, cover_page, params)
    entity = construct_defaults(params)
    rendered_body =
      body.render(sanitize_values(entity), { strict_variables: true })
    document_body =
      if cover_page
        rendered_cover_page =
          cover_page.render(
            sanitize_values(entity),
            { strict_variables: true }
          )
        rendered_cover_page + rendered_body
      else
        rendered_body
      end
    template =
      ApplicationController.new.render_to_string(
        inline: document_body,
        layout: 'layouts/ivl_pdf_layout'
      )

    return Failure(body.errors) if body.errors.present?

    Success({ rendered_template: template, entity: sanitize_values(entity) })
  end
end
# rubocop:enable Layout/MultilineMethodCallIndentation
# rubocop:enable Layout/MultilineOperationIndentation
