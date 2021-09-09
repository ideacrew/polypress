# frozen_string_literal: true

module Sections
  # Markup content associated with a {Sections::Section}
  class SectionItemBody < Dry::Struct
    attribute :content_type, Types::String
    attribute :encoding, Types::String
    attribute :markup, Types::String
    # attribute :schema, Schema
    # attribute :settings, Types::Array.of(Schemas::Setting)
  end
end
