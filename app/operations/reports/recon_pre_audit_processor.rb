# frozen_string_literal: true

module Reports
  # received an event from enroll to start the pre audit processor
  class ReconPreAuditProcessor
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])
    send(:include, ::EventSource::Command)
    send(:include, ::EventSource::Logging)

    def call(_params)
      _enabled = yield pre_audit_feature_enabled?
      carrier_ids = yield fetch_carrier_ids
      fetch_and_store_coverage_data(carrier_ids)
      Success(true)
    end

    private

    def pre_audit_feature_enabled?
      if PolypressRegistry.feature_enabled?(:pre_audit_report)
        Success(true)
      else
        Failure("Pre audit report should not be run")
      end
    end

    def fetch_carrier_ids
      Success(PolypressRegistry[:pre_audit_report].setting(:carrier_hios_ids).item)
    end

    def fetch_and_store_coverage_data(carrier_ids)
      carrier_ids.each do |carrier_hios_id|
        result = Reports::FetchAndStoreSubscribersAndCoverageHistory.new.call({ carrier_hios_id: carrier_hios_id, year: Date.today.year })
        result.success? ? publish_event_to_generate_report(carrier_hios_id) : Failure("Unable to generate report for hios_id #{carrier_hios_id}")
      end
    end

    def publish_event_to_generate_report(carrier_hios_id)
      payload = { carrier_hios_id: carrier_hios_id }
      event =   event("events.reports.generate_pre_audit_report",
                      attributes: { payload: payload }).success
      unless Rails.env.test?
        logger.info('-' * 100)
        logger.info(
          "Polypress to generate pre audit report, attributes: #{payload.to_h}"
        )
        logger.info('-' * 100)
      end
      event.publish
      Success("Successfully published event to polypress to generate ")
    end
  end
end