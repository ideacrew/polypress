# frozen_string_literal: true

module Sections
  # A standalone container that groups logically connected content
  # in a {Templates::Template}>
  class SectionItem < Dry::Struct
    # @!attribute [r] title
    # A human-friendly title for the template
    # @return [String]
    attribute :title, Types::String

    # @!attribute [r] kind
    # Classification of this Section that conveys intended use
    # @return [String]
    attribute :kind, Polypress::Types::SectionKind

    # @!attribute [r] description
    # An explanation of the purpose and use of this section
    # @return [String]
    attribute :description, Types::String

    # @!attribute [r] section_body
    # The content and composition to parse and render
    # @return [String]
    attribute :section_item_body, SectionItemBody

    # @!attribute [r] created_at
    # Timestamp when this this section was created
    # @return [Time]
    attribute :created_at, Types::Time

    # @!attribute [r] created_at
    # Date when this this section was last updated
    # @return [Time]
    attribute :updated_at, Types::Time

    # @!attribute [r] updated_by
    # The Account ID of the last person who updated this entity
    # @return [String]
    attribute :updated_by, Types::String

    # @!attribute [r] updated_by
    # The Account ID of the person who who originally created
    #  this entity
    # @return [String]
    attribute :author, Types::String
  end
end
