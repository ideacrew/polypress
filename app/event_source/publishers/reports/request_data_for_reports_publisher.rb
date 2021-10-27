# frozen_string_literal: true

module Publishers
  module Reports
    # Publisher will send payload with carrier id and year to EDI Gateway
    class RequestDataForReportsPublisher
      # TODO: enable below after eventsource initializer is updated acccordingly to acaentities async_api yml files
      include ::EventSource::Publisher[amqp: 'edi.reports']

      register_event 'subscribers_list_requested'
      register_event 'coverage_history_for_subscriber_requested'
    end
  end
end
