# frozen_string_literal: true

module Sections
  # Standalone containers that groups logically connected content
  # in a {Templates::Template}>
  class Section < Dry::Struct
    # @!attribute [r] key
    # Unique identifier for this entity
    # @return [Symbol]
    attribute :key, Types::String
  end
end
