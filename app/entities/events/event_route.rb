# frozen_string_literal: true

module Events
  # Assign a {Templates::Template} to generate a document based on an event name
  # and optionally its attribute content
  class EventRoute < Dry::Struct
    attribute :event_name, Types::String.meta(ommitable: false)
  end
end
