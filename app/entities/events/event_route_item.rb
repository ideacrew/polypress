# frozen_string_literal: true

module Events
  # Assign a {Templates::Template} to generate a document based on an event name
  # and optionally its attribute content
  class EventRouteItem
    attribute :attributes, Types::String.meta(ommitable: true)
    attribute :criteria, Types::String.meta(ommitable: true)
    attribute :template_key, Types::String.meta(ommitable: true)
  end
end
