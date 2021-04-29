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

  # TODO: Stub entity payload based on the recipient
  def stubbed_entity
    {
      'family' => {
        'family_members' => [{ 'hbx_id' => 464_747 }],
        'family_member' => { 'foreign_key' => { 'key' => 'KEY' }, 'hbx_id' => 464_747 },
        'timestamp' => { 'submitted_at' => 'TimeStamp' }
      }
    }
  end

  def render(parsed_template, params)
    entity = params[:instant_preview] || params[:preview] ? stubbed_entity : params[:entity].to_h
    rendered_template = parsed_template.render(entity, { strict_variables: true })

    parsed_template.errors.present? ? Failure(parsed_template.errors) : Success(rendered_template)
  end
end
