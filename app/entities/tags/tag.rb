# frozen_string_literal: true

module Tags
  # A key-value pair for assigning values to variables
  class Tag < Dry::Struct
    # @!attribute [r] namespace
    # Optional dot-notation string to
    # @return [Symbol]
    attribute :namespace, Types::Symbol.meta(omittable: false)

    # @!attribute [r] key
    # Identifier for the Tag.  Must be unique within a namespace  (required)
    # @return [Symbol]
    attribute :key, Types::Symbol.meta(omittable: false)

    # @!attribute [r] value
    # A value assigned to this named Tag (required)
    # @return [Symbol]
    attribute :value, Types::Any.meta(omittable: false)

    # @!attribute [r] description
    # Short description for the tag. CommonMark syntax can be used for
    # rich text representation
    # @return [String]
    attribute :description, Polypress::Types::String.meta(omittable: true)
  end
end
