# frozen_string_literal: true

module Entities
  module Templates
    class Main < Dry::Struct

      # @!attribute [r] sections
      # Represents a generic standalone section of a document
      # @return [Array<Sections::Section>]
      attribute :sections,             Polypress::Types::Array.of(Entities::Templates::Section).meta(omittable: true)
      attribute :content,              Polypress::Types::Array.of(Entities::Templates::Section).meta(omittable: true)

    end
  end
end