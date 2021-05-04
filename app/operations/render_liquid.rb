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
    template = Liquid::Template.parse(params[:body])
    Success(template)
  rescue StandardError => e
    Failure(e)
  end

  # TODO: Stub entity payload based on the recipient
  def stubbed_entity
    family_hash
  end

  def render(parsed_template, params)
    entity = params[:instant_preview] || params[:preview] ? stubbed_entity : params[:entity].to_h
    rendered_template = parsed_template.render(entity&.deep_stringify_keys, { strict_variables: true })

    parsed_template.errors.present? ? Failure(parsed_template.errors) : Success(rendered_template)
  end
end
