# frozen_string_literal: true

module EventRoutes
  # Mongoid peristance model for {Templates::Template} entity
  class EventRouteModel
    include Mongoid::Document
    include Mongoid::Timestamps

    embedded_in :publisher_event,
                inverse_of: :publisher,
                class_name: 'Templates::TemplateModel'

    embedded_in :subscriber_event,
                inverse_of: :subscriber,
                class_name: 'Templates::TemplateModel'

    field :event_name, type: String
    field :event_attributes, type: Hash
    field :filter_criteria, type: String
  end
end
