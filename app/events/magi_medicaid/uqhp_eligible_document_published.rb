# frozen_string_literal: true

module MagiMedicaid
  # Publishes uqhp eligible document created event
  class UqhpEligibleDocumentPublished < EventSource::Event

    publisher_key 'magi_medicaid.eligibilities_publisher'

    # attribute_keys :hbx_id, :legal_name, :fein, :entity_kind

    # TODO: Attribute managment
    # Default behavior is to include all attributes in Envent payload
    # Add ability to map/transform event instance attributes to payload attributes
    # Use Dry-Transform for this function

    # TODO: Add Event Stream Reference (to EventSource::Event)

    # Use #apply to update the source model record
    def apply(instance)
    end
  end
end