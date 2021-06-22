# frozen_string_literal: true

# RenderLiquid
class RenderLiquid
  send(:include, FamilyHelper)
  send(:include, Dry::Monads[:result, :do])

  # @param [String] :body
  # @param [String] :subject MPI indicator for a given notice
  # @param [Array<Dry::Struct>] :entities
  # @param [Hash] :options
  # @return [Dry::Monads::Result] Parsed template as string
  def call(params)
    parsed_cover_page = yield parse_cover_page
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
    # I used a regular expression to gsub both; double and single quotes
    # instead of having to gsub twice.
    body = (params[:body] || params[:template].body).gsub(
      /&quot;|&#39;/,
      # Below is just the mapping for the regular expression.
      # It simply tells the gsub method what to replace for each
      # matched value.
      {
        '&quot;' => "\"",
        "&#39;" => "\'"
      }
    )
    template = Liquid::Template.parse(body, line_numbers: true)
    Success(template)
  rescue StandardError => e
    Failure(e)
  end

  def entity_hash(params)
    entity = params[:instant_preview] || params[:preview] ? application_hash : params[:entity].to_h
    oe_end_on_year = entity[:oe_start_on].year + 1
    settings_hash = {
      :notice_number => params[:subject],
      :short_name => Settings.site.short_name,
      :marketplace_phone => Settings.contact_center.short_number,
      :marketplace_url => Settings.site.website_url,
      :oe_end_on => Date.new(oe_end_on_year, 1, 31)
    }
    entity.merge(settings_hash)
  end

  def render(body, cover_page, params)
    entity = entity_hash(params)
    rendered_cover_page = cover_page.render(entity&.deep_stringify_keys, { strict_variables: true })
    rendered_body = body.render(entity&.deep_stringify_keys, { strict_variables: true })
    template = ApplicationController.new.render_to_string(inline: rendered_cover_page + rendered_body, layout: 'layouts/ivl_pdf_layout')

    return Failure(body.errors + cover_page.errors) if body.errors.present? || cover_page.errors.present?

    Success({ rendered_template: template, entity: entity })
  end
end
