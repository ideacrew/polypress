# frozen_string_literal: true

module EventRoutes
  # Event reference for document publish and subscribe operations
  class EventRoute < Dry::Struct
    # @!attribute [r] event_name
    # The unique identifier for the Event
    # @return [String]
    attribute :event_name, Types::String.meta(ommitable: false)

    # # @!attribute [r] attributes
    # Optional Event attribute payload
    # @return [Hash]
    attribute :event_attributes,
              Types::Hash.optional.default({}).meta(ommitable: true)

    # # @!attribute [r] filter_criteria
    # Additional, optional attribute-based criteria used when necessary to
    # match Event to a Template
    # @return [String]
    attribute :filter_criteria,
              Types::String.optional.default('').meta(ommitable: true)
  end
end
