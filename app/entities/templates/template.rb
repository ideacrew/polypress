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

    # @!attribute [r] subject
    # Reference to the person/topic that output document discusses/deals with
    # For example, notice_number: IVL_FEL
    # @return [String]
    # attribute :subject, Types::String.meta(omittable: true)

    # @!attribute [r] description
    # A verbose explanation of the template.
    # @return [String]
    attribute :description, Types::String.meta(omittable: true)

    # @!attribute [r] locale
    # Template's written Language
    # @return [String]
    attribute :locale, Types::String.optional.meta(omittable: true)

    # @!attribute [r] locale
    # Template's written Language
    # @return [String]
    attribute :content_type, Types::String.optional.meta(omittable: true)

    attribute :print_code, Types::String.optional.meta(omittable: true)

    # @!attribute [r] category
    # Defines the top level group for this template
    # @return [String]
    attribute :marketplace,
              AcaEntities::Types::MarketPlaceKinds.meta(omittable: false)

    attribute :markup_section, Types::String.optional.meta(omittable: true)

    attribute :author, Types::String.optional.meta(omittable: true)

    attribute :updated_by, Types::String.optional.meta(omittable: true)

    attribute :created_at, Types::Time.optional.meta(omittable: true)

    attribute :updated_at, Types::Time.optional.meta(omittable: true)

    def create_model
      values = sanitize_attributes

      result = Templates::TemplateModel.create(values)
      result ? Success(result) : Failure(result)
    end

    def update_model(record_id)
      values = sanitize_attributes

      template = Templates::TemplateModel.find(record_id)
      result = template.update_attributes(values)

      result ? Success(result) : Failure(result)
    end

    # Strip any Mondoid-managed attributes from hash
    def sanitize_attributes
      to_h.reject { |k, v| Polypress::Types::MongoidPrivateKeys.include?(k) }
    end
  end
end
