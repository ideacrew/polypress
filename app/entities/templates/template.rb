# frozen_string_literal: true

module Templates
  # Definition - typically combined with merged data - for generating a
  # structured document.  The class includes information about subscribe
  # and publish events that enable automatated document creation and
  # distribution
  class Template < Dry::Struct
    include Dry::Monads[:result, :do, :try]

    # @!attribute [r] key
    # The backing store's unique identifier for this entity
    # @return [Symbol]
    attribute :_id, Types::String.meta(omittable: true) # unique identifier

    # @!attribute [r] key
    # Unique identifier for this entity
    # @return [Symbol]
    attribute :key, Types::String.optional.meta(omittable: true) # unique identifier

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
    # The document content and composition to parse and render
    # @return [Bodies::Body]
    attribute :body, Bodies::Body.optional.meta(omittable: true)

    # @!attribute [r] content_type
    # The mime type of the generated document
    # @return [String]
    attribute :content_type, Types::String.optional.meta(omittable: true)

    # @!attribute [r] print_code
    # Customer-assigned code reference reagarding the subject or topic of the
    # generated document
    # For example, notice_number: IVL_FEL
    # @return [String]
    attribute :print_code, Types::String.optional.meta(omittable: true)

    # @!attribute [r] marketplace
    # The system marketplace that this document belongs to
    # @return [String]
    attribute :marketplace,
              AcaEntities::Types::MarketPlaceKinds.meta(omittable: false)

    # @!attribute [r] publisher
    # The Event used to publish a document generated from this Template
    # @return [EventRoutes::EventRoute]
    attribute :publisher, EventRoutes::EventRoute.optional.meta(omittable: true)

    # @!attribute [r] subscriber
    # The Event that triggers generation of a document using this template
    # @return [EventRoutes::EventRoute]
    attribute :subscriber,
              EventRoutes::EventRoute.optional.meta(omittable: true)

    # @!attribute [r] author
    # The Account ID of person who created this Template
    # @return [String]
    attribute :author, Types::String.optional.meta(omittable: true)

    # @!attribute [r] updated_by
    # The Account ID of the person who last updated this entity
    # @return [String]
    attribute :updated_by, Types::String.optional.meta(omittable: true)

    attribute :recipient, Types::String.optional.meta(omittable: true)
    attribute :published_at, Types::Date.optional.meta(omittable: true)

    # @!attribute [r] created_at
    # Timestamp when this entity was created
    # @return [Time]
    attribute :created_at, Types::Time.meta(omittable: true)

    # @!attribute [r] updated_at
    # Date when this entity was last updated
    # @return [Time]
    attribute :updated_at, Types::Time.meta(omittable: true)

    attribute :paper_communication_override, Types::Bool.optional.meta(omittable: true)

    # Persist the template to the backing store
    def create_model
      values = sanitize_attributes

      result = Templates::TemplateModel.create(values)
      result ? Success(result) : Failure(result)
    end

    # Update the template in the backing store
    def update_model(record_id)
      values = sanitize_attributes

      template = Templates::TemplateModel.find(record_id)
      result = template.update_attributes(values)

      result ? Success(result) : Failure(result)
    end

    private

    # Strip any Mondoid-managed attributes from hash
    def sanitize_attributes
      to_h.reject { |k, _v| Polypress::Types::MONGOID_PRIVATE_KEYS.include?(k) }
    end
  end
end
