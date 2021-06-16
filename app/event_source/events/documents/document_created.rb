# frozen_string_literal: true

module Events
  module Documents
    # Will register publisher event for Polypress
    class DocumentCreated < EventSource::Event
      publisher_path 'publishers.document_meta_data_publisher'

    end
  end
end