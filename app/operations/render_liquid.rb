# frozen_string_literal: true

require 'yaml'

# RenderLiquid
class RenderLiquid
  send(:include, Dry::Monads[:result, :do])

  # @param [Templates::Template] :template
  # @param [Array<Dry::Struct>] :entities
  # @return [Dry::Monads::Result] Parsed template as string
  def call(params)
    parsed_template = yield parse(params)
    template = yield render(parsed_template, params[:entity])

    Success(template)
  end

  private

  def parse(params)
    template = Liquid::Template.parse(params[:body])

    template ? Success(template) : Failure('Unable to parse template')
  end

  def render(parsed_template, entity)
    rendered_template = parsed_template.render(entity.to_h)
    Success(rendered_template)
  end
end
