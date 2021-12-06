# frozen_string_literal: true

require 'faraday'

module Reports
  # request glue to get coverage history for subscriber
  class RequestCoverageHistoryForSubscriber
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    def call(params)
      valid_params = yield validate(params)
      service_uri = yield fetch_coverage_history_end_point
      user_token = yield fetch_user_token
      coverage_history_response = yield fetch_coverage_history(service_uri, user_token, valid_params)
      status = yield store_coverage_history(coverage_history_response, valid_params[:audit_report_datum])
      Success(status)
    end

    private

    def validate(params)
      return Failure("No audit datum record") if params[:audit_report_datum].blank?
      return Failure("No audit report execution record") if params[:audit_report_execution].blank?

      Success(params)
    end

    def fetch_coverage_history_end_point
      result = Try do
        PolypressRegistry[:gluedb_integration].setting(:gluedb_enrolled_subjects_coverage_history_uri).item
      end

      return Failure("Failed to find setting: :gluedb_integration, :gluedb_enrolled_subjects_coverage_history_uri") if result.failure?
      result.nil? ? Failure(":gluedb_enrolled_subjects_coverage_history_uri cannot be nil") : result
    end

    def fetch_user_token
      result = Try do
        PolypressRegistry[:gluedb_integration].setting(:gluedb_user_access_token).item
      end

      return Failure("Failed to find setting: :gluedb_integration, :gluedb_user_access_token") if result.failure?
      result.nil? ? Failure(":gluedb_user_access_token cannot be nil") : result
    end

    def fetch_coverage_history(service_uri, user_token, valid_params)
      audit_report_execution = valid_params[:audit_report_execution]
      audit_datum = valid_params[:audit_report_datum]
      params = { id: audit_datum.subscriber_id,
                 year: audit_report_execution.audit_year,
                 hios_id: audit_report_execution.hios_id,
                 user_token: user_token }

      response = Faraday.get(service_uri, params)

      response.status == 200 ? Success(response.body) : Failure("Unable to fetch coverage history due to #{response.body}")
    end

    def store_coverage_history(coverage_history_response, audit_datum)
      Success(audit_datum.update_attributes(payload: coverage_history_response, status: "completed"))
    end
  end
end