# frozen_string_literal: true

module Reports
  # received an event from enroll to start the pre audit processor
  class ReconPreAuditProcessor
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])
    send(:include, ::EventSource::Command)
    send(:include, ::EventSource::Logging)

    def call(params)
      @year = params[:year]
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
        result = Reports::FetchAndStoreSubscribersAndCoverageHistory.new.call({ carrier_hios_id: carrier_hios_id, year: @year })
        result.success? ? Success(:ok) : Failure("Unable to generate report for hios_id #{carrier_hios_id}")
      end
    end
  end
end