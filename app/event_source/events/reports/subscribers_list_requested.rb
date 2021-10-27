# frozen_string_literal: true

module Events
  module Reports
    # Will register publisher event for Polypress
    class SubscribersListRequested < EventSource::Event
      publisher_path 'publishers.reports.request_data_for_reports_publisher'

    end
  end
end