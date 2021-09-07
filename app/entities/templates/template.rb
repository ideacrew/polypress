# frozen_string_literal: true

class Template
  # @!attribute [r] key
  # Unique identifier for this entity
  # @return [Symbol]
  attribute :key, Types::Symbol.meta(omittable: false) # unique identifier

  # @!attribute [r] title
  # A human-friendly title for the template
  # @return [String]
  attribute :title, Types::String

  # @!attribute [r] description
  # A verbose explanation of the template.
  # @return [String]
  attribute :description, Types::String

  # @!attribute [r] sections
  # A collection of standalone content components to parse and render for
  # this template
  # @return [String]
  attribute :sections, Sections::Section

  # @!attribute [r] locale
  # Template's written Language
  # @return [String]
  attribute :locale, Polypress::Types::String.optional.meta(omittable: true)

  # @!attribute [r] subject
  # Reference to the person/topic that output document discusses/deals with
  # For example, notice_number: IVL_FEL
  # @return [String]
  attribute :subject, Polypress::Types::String.meta(omittable: false)

  # @!attribute [r] category
  # Defines the top level group for this template
  # @return [String]
  attribute :category, Polypress::Types::CategoryKind.meta(omittable: false)

  # @!attribute [r] order
  # The order in which the sections render in the document
  # @return [Array<String>]
  attribute :order, Types::Array.of(Types::Symbol)

  # @!attribute [r] tags
  # A list of tags for logical grouping of templates
  # @return [Array<Tag>]
  attribute :tags,
            Polypress::Types::Array
              .of(Entities::Tags::Tag)
              .optional
              .meta(omittable: true)
end
