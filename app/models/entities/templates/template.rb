# frozen_string_literal: true

module Entities
  module Templates
    # A Template contains structured and unstructured text and associated content to be output into a document
    class Template < Dry::Struct
      # @!attribute [r] key
      # Unique identifier that links document to a particular event
      # @return [Symbol]
      attribute :key, Polypress::Types::Symbol.meta(omittable: false) # unique identifier

      # @!attribute [r] title
      # A human-friendly title for the template
      # @return [String]
      attribute :title, Polypress::Types::String.meta(omittable: false)

      # @!attribute [r] description
      # A verbose explanation of the template.
      # @return [String]
      attribute :description, Polypress::Types::String.meta(omittable: false)

      # @!attribute [r] inserts
      # Determines Inserts for the document. Ex: Appeals, Discrimination Page
      # @return [String]
      attribute :inserts, Polypress::Types::Array.optional.meta(omittable: true)

      # @!attribute [r] doc_type
      # Determines the type of documents. Ex: Notice, Insert
      # @return [String]
      attribute :doc_type, Polypress::Types::Symbol.meta(omittable: false)

      # @!attribute [r] content_type
      # The content type to use when encoding/decoding a template's payload. The value must be a
      # specific media type confirms to (e.g. application/json).
      # @return [String]
      attribute :content_type, Polypress::Types::String

      # @!attribute [r] recipient
      # Namespace to whom the output document is directed
      # @return [String]
      attribute :recipient, Polypress::Types::String.meta(omittable: false)

      # @!attribute [r] cc_recipients
      # Namespace to whom the output document is copied
      # @return [String]
      attribute :cc_recipients,
                Polypress::Types::Array
                  .of(Polypress::Types::String)
                  .optional
                  .meta(omittable: true)

      # @!attribute [r] locale
      # Template's written Language
      # @return [String]
      attribute :locale, Polypress::Types::String.optional.meta(omittable: true)

      # @!attribute [r] contracts
      # An array of domain models used to merge attributes into the template
      # @return [Array<Dry::Validation::Contract>]
      attribute :contracts,
                Polypress::Types::Array.optional.meta(omittable: true)

      attribute :body, Polypress::Types::String.meta(omittable: false)

      # attribute :body,          Polypress::Types::Array.of(Bodies::Body).meta(omittable: true)

      # @!attribute [r] subject
      # Reference to the person/topic that output document discusses/deals with
      # For example, notice_number: IVL_FEL
      # @return [String]
      attribute :subject, Polypress::Types::String.meta(omittable: false)

      # @!attribute [r] category
      # Defines the top level group for this template
      # @return [String]
      attribute :category, Polypress::Types::CategoryKind.meta(omittable: false)

      # settings passed into the formatter(s) to build documents
      # attribute :options, Polypress::Types::Array.of(Options::Option).meta(omittable: true)

      # @!attribute [r] tags
      # A list of tags for logical grouping of templates
      # @return [Array<Tag>]
      # attribute :tags,           Polypress::Types::Array.of(Entities::Tags::Tag).optional.meta(omittable: true)
    end
  end
end
