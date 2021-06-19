# frozen_string_literal: true

# RenderLiquid
class RenderLiquid
  send(:include, FamilyHelper)
  send(:include, Dry::Monads[:result, :do])

  # @param [Templates::Template] :template
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
    template = Liquid::Template.parse(params[:body], line_numbers: true)
    Success(template)
  rescue StandardError => e
    Failure(e)
  end

  def render(body, cover_page, params)
    entity = params[:instant_preview] || params[:preview] ? application_hash : params[:entity].to_h
    rendered_cover_page = cover_page.render(entity&.deep_stringify_keys, { strict_variables: true })
    rendered_body = body.render(entity&.deep_stringify_keys, { strict_variables: true })
    template = ApplicationController.new.render_to_string(inline: rendered_cover_page + rendered_body, layout: 'layouts/ivl_pdf_layout')

    return Failure(body.errors + cover_page.errors) if body.errors.present? || cover_page.errors.present?

    Success({ rendered_template: template, entity: entity })
  end
end
