# frozen_string_literal: true

module Reports
  class ReconPreAuditProcessor
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])
    send(:include, ::EventSource::Command)
    send(:include, ::EventSource::Logging)
    require 'securerandom'

    def call(_params)
      _enabled = yield pre_audit_feature_enabled?
      carrier_ids = yield fetch_carrier_ids
      build_event_and_publish(carrier_ids)
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
      Success(PolypressRegistry[:pre_audit_report].setting(:carrier_hbx_ids).item)
    end

    def build_event_and_publish(carrier_ids)
      carrier_ids.each do |carrier_hbx_id|
        audit_report_execution = AuditReportExecution.new(correlation_id: SecureRandom.uuid.gsub("-",""),
                                                          report_kind: "pre_audit",
                                                          status: "pending",
                                                          audit_year: Date.today.year,
                                                          hios_id: carrier_hbx_id)
        audit_report_execution.save!

        payload = { carrier_hbx_id: carrier_hbx_id,
                    year: Date.today.year,
                    report_kind: "pre_audit" }

        event = event("events.reports.subscribers_list_requested",
                      attributes: { payload: payload },
                      headers: { correlation_id: audit_report_execution.correlation_id }).success
        unless Rails.env.test?
          logger.info('-' * 100)
          logger.info(
            "Polypress sends request to edi gateway for subscribers list,
            event_key: events.edi.reports.subscribers_list_requested, attributes: #{payload.to_h}"
          )
          logger.info('-' * 100)
        end
        event.publish
        Success("Successfully published event to edi gateway to fetch subscribers list for carrier id #{carrier_hbx_id} ")
      end
    end
  end
end