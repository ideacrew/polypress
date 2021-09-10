# frozen_string_literal: true

module Templates
  class Template < Dry::Struct
    include Dry::Monads[:result, :do, :try]

    attribute :_id, Types::String.meta(omittable: true) # unique identifier

    # @!attribute [r] key
    # Unique identifier for this entity
    # @return [Symbol]
    attribute :key, Types::String.meta(omittable: false) # unique identifier

    # @!attribute [r] title
    # A human-friendly title for the template
    # @return [String]
    attribute :title, Types::String.meta(omittable: false)

    # attribute :subject, Types::String.meta(omittable: true)

    # @!attribute [r] description
    # A verbose explanation of the template.
    # @return [String]
    attribute :description, Types::String.meta(omittable: true)

    # @!attribute [r] locale
    # Template's written Language
    # @return [String]
    attribute :locale, Types::String.optional.meta(omittable: true)

    # @!attribute [r] body
    # The content and composition to parse and render
    # @return [Bodies::Body]
    attribute :body, Bodies::Body.meta(omittable: true)

    # @!attribute [r] locale
    # Template's written Language
    # @return [String]
    attribute :content_type, Types::String.optional.meta(omittable: true)

    # @!attribute [r] print_code
    # Reference to the person/topic that output document discusses/deals with
    # For example, notice_number: IVL_FEL
    # @return [String]
    attribute :print_code, Types::String.optional.meta(omittable: true)

    # @!attribute [r] marketplace
    # @return [String]
    attribute :marketplace,
              AcaEntities::Types::MarketPlaceKinds.meta(omittable: false)

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

    def create_model
      values = sanitize_attributes

      result = Templates::TemplateModel.create(values)
      result ? Success(result) : Failure(result)
    end

    # Strip any Mondoid-managed attributes from hash
    def sanitize_attributes
      to_h.reject { |k, v| Polypress::Types::MongoidPrivateKeys.include?(k) }
    end
  end
end
