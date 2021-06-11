# frozen_string_literal: true

module Entities
  # Allows adding meta data to a single tag
  module Tags
    # Allows adding metadata to a single tag
    class Tag < Dry::Struct
      # @!attribute [r] name
      # Tag name (required)
      # @return [Symbol]
      attribute :name,            Polypress::Types::Symbol.meta(omittable: false)
      # @!attribute [r] description
      # Short description for the tag. CommonMark syntax can be used for
      # rich text representation
      # @return [String]
      attribute :description,     Polypress::Types::String.meta(omittable: true)
    end
  end
end