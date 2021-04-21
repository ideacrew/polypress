# frozen_string_literal: true

require 'yaml'

# RenderLiquid
class RenderLiquid
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
    template = Liquid::Template.parse(params[:body])

    template ? Success(template) : Failure('Unable to parse template')
  end

  def render(parsed_template, params)
    rendered_template = parsed_template.render(params[:entity].to_h, params[:options])

    Success(rendered_template)
  end
end
