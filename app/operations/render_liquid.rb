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
    parsed_template = yield parse(params)
    template = yield render(parsed_template, params)

    Success(template)
  end

  private

  def parse(params)
    html_string = (ApplicationController.new.render_to_string(template: 'templates/ivl_template', layout: false) + params[:body].html_safe).to_str
    template = Liquid::Template.parse(html_string, line_numbers: true)
    Success(template)
  rescue StandardError => e
    Failure(e)
  end

  def render(parsed_template, params)
    entity = params[:instant_preview] || params[:preview] ? application_hash : params[:entity].to_h
    rendered_template = parsed_template.render(entity&.deep_stringify_keys, { strict_variables: true })

    parsed_template.errors.present? ? Failure(parsed_template.errors) : Success({ rendered_template: rendered_template, entity: entity })
  end
end
