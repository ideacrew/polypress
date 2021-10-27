# frozen_string_literal: true

module Reports
  class RequestCoverageHistoryForSubscriber
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])
    send(:include, ::EventSource::Command)
    send(:include, ::EventSource::Logging)

    def call(params)
      valid_params = validate(params)
      _enabled = yield pre_audit_feature_enabled?
      _status = yield update_subscribers_count(valid_params)
      request_policies_for_subscriber(valid_params[:payload], valid_params[:correlation_id])
      Success(true)
    end

    private

    def validate(params)
      return Failure("No subscribers present") if params[:payload].blank?
      return Failure("No correlation id exists in headers") if params[:correlation_id].blank?

      Success(true)
    end

    def update_subscribers_count(valid_params)
      audit_report = AuditReportExecution.where(correlation_id: valid_params[:correaltion_id]).first
      audit_report.update_attributes(record_count: valid_params[:payload].count)

      Success(true)
    end

    def pre_audit_feature_enabled?
      if PolypressRegistry.feature_enabled?(:pre_audit_report)
        Success(true)
      else
        Failure("Pre audit report should not be run")
      end
    end

    def request_policies_for_subscriber(subscribers_list, correlation_id)
      subscribers_list.each do |subscriber_id|
        audit_datum = create_audit_report_datum(subscriber_id, correlation_id)
        payload = { subscriber_hbx_id: subscriber_id }
        build_event_and_publish(payload, audit_datum.correlation_id)
      end
    end

    def create_audit_report_datum(subscriber_id, correlation_id)
      audit_datum = AuditReportDatum.new(subscriber_id: subscriber_id,
                                         status: "pending",
                                         correlation_id: correlation_id)

      audit_datum.save!
      audit_datum
    end

    def build_event_and_publish(payload, correlation_id)
      event =   event("events.reports.coverage_history_for_subscriber_requested",
                      attributes: { payload: payload }, headers: { correlation_id: correlation_id }).success
      unless Rails.env.test?
        logger.info('-' * 100)
        logger.info(
          "Polypress sends request to edi gateway to get coverage history for a subscriber,
          event_key: events.polypress.reports.coverage_history_for_subscriber_requested, attributes: #{payload.to_h}"
        )
        logger.info('-' * 100)
      end
      event.publish
      Success("Successfully published event to edi gateway to get coverage history for a subscriber")
    end
  end
end