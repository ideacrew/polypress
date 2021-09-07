# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Sections
  # Operation to create template
  class Render
    def call(params)
      values = yield validate(params)
      html_doc = yield rendor(values)

      Success(html_doc)
    end

    private

    def validate(params)
      Contracts::Sections::Section.new.call(params)
    end

    def render(values)
      Try() do
        Liquid::Template.parse(
          values[:section_body][:markdown],
          error_mode: :strict
        )
        # rubocop:disable Style/MultilineBlockChain
      end.bind do |result|
        # rubocop:enable Style/MultilineBlockChain
        return result unless result.success?
        liquid_template = result.value!
        doc = liquid_template.render(values[:section_body][:settings])

        if doc.errors.empty?
          Success(doc)
        else
          Failure("errors rendering section: #{values[:key]}\n #{doc.errors}")
        end
      end
    end
  end
end
