# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Templates
  # Create a Liquid::Template instance that parses and renders the content of
  # a {Sections::SectionItem}
  class Render
    include Dry::Monads[:result, :do, :try]

    # @param [Hash] opts the parameters to render a SectionItem
    # @option opts [Hash] :template required
    # @option opts [Hash] :attributes optional
    # @return [Dry::Monad] result
    # @return [Dry::Monad::Failure(Array<Liquid::UndefinedVariable>)] if parsing errors occur
    def call(params)
      values = yield validate(params)
      html_doc = yield render(values)
      Success(html_doc)
    end

    private

    def validate(params)
      attributes = params[:attributes] || {}
      result = Templates::TemplateContract.new.call(params[:template].to_h)

      if result.success?
        Success({ template: result.to_h, attributes: attributes })
      else
        Failure(result)
      end
    end

    def render(values)
      # Try() do

      begin
        parsed_doc = Liquid::Template.parse(
          values[:template][:body][:markup],
          error_mode: :strict,
          line_numbers: true
        )
      rescue StandardError => e
        return Failure(e)
      end

      # end.bind do |parsed_doc|
      return Failure(parsed_doc) if parsed_doc.errors.present?

      rendered_doc =
        parsed_doc.render(
          values[:attributes].deep_stringify_keys,
          { strict_variables: true }
        )

      if parsed_doc.errors.present? || rendered_doc.to_s.empty?
        Failure(parsed_doc)
      else
        Success(rendered_doc)
      end

      # end
    end
  end
end
