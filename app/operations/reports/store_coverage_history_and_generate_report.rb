# frozen_string_literal: true

module Reports
  #Store coverage history for a subscriber and publish event to generate report
  class StoreCoverageHistoryAndGenerateReport
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])
    send(:include, ::EventSource::Command)
    send(:include, ::EventSource::Logging)

    def call(params)
      valid_params = validate(params)
      status = yield fetch_and_update_subscriber(valid_params)
      build_event_and_publish
      Success(true)
    end

    private

    def validate(params)
      return Failure("No subscriber id present") if params[:payload][:subscriber_id].blank?
      return Failure("No coverage history present for a subscriber") if params[:payload][:coverage_history].blank?
      return Failure("No correlation id exists in headers") if params[:correlation_id].blank?

      Success(true)
    end

    def fetch_and_update_subscriber(valid_params)
      @audit_report = AuditReportExecution.where(correlation_id: valid_params[:correlation_id]).first
      audit_datum = @audit_report.audit_report_datum.where(subscriber_id: valid_params[:subscriber_id]).first

      return Failure("Unable to find report datum object") if audit_datum.blank?

      audit_datum.update_attributes(status: "complete", payload: valid_params[:coverage_history])
      Success(true)
    end

    def build_event_and_publish
      audit_datum_count = @audit_report.audit_datum.where(status: "complete").count
      audit_report_subscriber_count = @audit_report.subscriber_count
      return unless audit_report_subscriber_count == audit_datum_count

      event = event("events.reports.generate_pre_audit_report").success
      unless Rails.env.test?
        logger.info('-' * 100)
        logger.info(
          "Polypress sends event to to start pre audit report,
        event_key: events.reports.generate_pre_audit_report"
        )
        logger.info('-' * 100)
      end
      event.publish
      Success("Successfully published event to polypress to generate pre audit report")
    end
  end
end