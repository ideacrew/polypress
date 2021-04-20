# frozen_string_literal: true

# require_relative 'operations/document/create'

module Entities
  module Templates
    # A Section is a content fragment
    class Section < Dry::Struct

      attribute :index,     Types::Integer.meta(omittable: true) # Manages the order in which composition appears in template
      attribute :key,       Types::String.meta(omittable: true) # Literal text with embedded markdown
      attribute :namespace, Types::String.meta(omittable: true) # Literal text with embedded markdown
      attribute :content,   Types::Array.of(Templates::Section).meta(omittable: true)

    end
  end
end