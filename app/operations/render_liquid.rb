# frozen_string_literal: true

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
    Success(template)
  rescue StandardError => e
    Failure(e)
  end

  def render(parsed_template, params)
    rendered_template = parsed_template.render(params[:entity].to_h, { strict_variables: true })

    if parsed_template.errors.present?
      Failure(parsed_template.errors)
    else
      Success(rendered_template)
    end
  end
end
