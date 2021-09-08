# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Sections
  # Create a Liquid::Template instance that parses and renders the content of
  # a {Sections::SectionItem}
  class RenderSectionItem
    include Dry::Monads[:result, :do, :try]

    # @param [Hash] opts the parameters to render a SectionItem
    # @option opts [Hash] :section_item required
    # @option opts [Hash] :attributes optional
    # @return [Dry::Monad] result
    def call(params)
      values = yield validate(params)
      html_doc = yield render(values)

      Success(html_doc)
    end

    private

    def validate(params)
      attributes = params[:attributes] || {}
      result = Sections::SectionItemContract.new.call(params[:section_item])

      if result.success?
        Success({ section_item: result.to_h, attributes: attributes })
      else
        Failure(result)
      end
    end

    # rubocop:disable Metrics/MethodLength
    def render(values)
      Try() do
        Liquid::Template.parse(
          values[:section_item][:section_item_body][:markup],
          error_mode: :strict,
          line_numbers: true
        )
        # rubocop:disable Style/MultilineBlockChain
      end.bind do |parsed_doc|
        # rubocop:enable Style/MultilineBlockChain

        if parsed_doc.errors.present?
          return(
            Failure(
              "errors parsing section #{values[:title]}: #{parsed_doc.errors}"
            )
          )
        end

        rendered_doc =
          parsed_doc.render(
            values[:attributes].deep_stringify_keys,
            { strict_variables: true }
          )

        if parsed_doc.errors.present?
          Failure(
            "section #{values[:title]} render error: #{parsed_doc.errors}"
          )
        elsif rendered_doc.to_s.empty?
          Failure("section #{values[:title]} render: output empty")
        else
          Success(rendered_doc)
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
