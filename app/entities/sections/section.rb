# frozen_string_literal: true

module Sections
  # Standalone containers that groups logically connected content
  # in a {Templates::Template}>
  class Section < Dry::Struct
    include Dry::Monads[:result, :do, :try]

    attribute :_id, Types::String.meta(omittable: true) # unique identifier

    # @!attribute [r] key
    # Unique identifier for this entity
    # @return [Symbol]
    attribute :key, Types::String.meta(omittable: false)

    attribute :section_item do
      # @!attribute [r] title
      # A human-friendly title for the template
      # @return [String]
      attribute :title, Types::String.meta(omittable: false)

      # @!attribute [r] description
      # An explanation of the purpose and use of this section
      # @return [String]
      attribute :description, Types::String.meta(omittable: true)

      # @!attribute [r] locale
      # Language for this section
      # @return [String]
      attribute :locale, Types::String.meta(omittable: true)

      # @!attribute [r] body
      # The content and composition to parse and render
      # @return [Bodies::Body]
      attribute :body, Bodies::Body.meta(omittable: true)

      # @!attribute [r] updated_by
      # The Account ID of the person who who originally created
      #  this entity
      # @return [String]
      attribute :author, Types::String.meta(omittable: true)

      # @!attribute [r] updated_by
      # The Account ID of the last person who updated this entity
      # @return [String]
      attribute :updated_by, Types::String.meta(omittable: true)

      # @!attribute [r] created_at
      # Timestamp when this this entity was created
      # @return [Time]
      attribute :created_at, Types::Time.meta(omittable: true)

      # @!attribute [r] updated_at
      # Date when this this entity was last updated
      # @return [Time]
      attribute :updated_at, Types::Time.meta(omittable: true)
    end

    def create_model
      values = flatten_map

      result = Sections::SectionModel.create(values)
      result ? Success(result) : Failure(result)
    end

    def flatten_map
      params = to_h.delete(:section_item).merge!(key: to_h[:key])
      sanitize_attributes(params)
    end

    # Strip any Mondoid-managed attributes from hash
    def sanitize_attributes(params)
      params.reject { |k, v| Polypress::Types::MongoidPrivateKeys.include?(k) }
    end
  end
end
