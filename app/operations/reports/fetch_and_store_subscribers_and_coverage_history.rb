# frozen_string_literal: true

require 'faraday'

module Reports
  # make an http call to glue to fetch subscriber list and coverage info
  class FetchAndStoreSubscribersAndCoverageHistory
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    def call(params)
      audit_report_execution = yield create_audit_report_execution(params)
      service_uri = yield fetch_subscriber_list_end_point
      user_token = yield fetch_user_token
      subscribers_list = yield fetch_subscribers_list(service_uri, user_token, audit_report_execution)
      _status = yield store_subscribers_list(subscribers_list, audit_report_execution)
      fetch_and_store_coverage_history(audit_report_execution)
      Success(true)
    end

    private

    def fetch_subscriber_list_end_point
      result = Try do
        PolypressRegistry[:gluedb_integration].setting(:gluedb_enrolled_subjects_uri).item
      end

      return Failure("Failed to find setting: :gluedb_integration, :gluedb_enrolled_subjects_uri") if result.failure?
      result.nil? ? Failure(":gluedb_enrolled_subjects_uri cannot be nil") : result
    end

    def fetch_user_token
      result = Try do
        PolypressRegistry[:gluedb_integration].setting(:gluedb_user_access_token).item
      end

      return Failure("Failed to find setting: :gluedb_integration, :gluedb_user_access_token") if result.failure?
      result.nil? ? Failure(":gluedb_user_access_token cannot be nil") : result
    end

    def create_audit_report_execution(params)
      Success(AuditReportExecution.create!(report_kind: "pre_audit",
                                           status: "pending",
                                           audit_year: params[:year],
                                           hios_id: params[:carrier_hios_id]))
    end

    def fetch_subscribers_list(service_uri, user_token, audit_report_execution)
      params = { year: Date.today.year == 2021 ? "2022" : Date.today.year,
                 hios_id: audit_report_execution.hios_id,
                 user_token: user_token }

      response = Faraday.get(service_uri, params)

      response.status == 200 ? Success(response.body) : Failure("Unable to fetch subscribers list due to #{response.body}")
    end

    def store_subscribers_list(subscribers_json, audit_report_execution)
      parsed_subscriber_list = JSON.parse(subscribers_json)
      parsed_subscriber_list.each do |subscriber_id|
        audit_report_execution.audit_report_datum << AuditReportDatum.new(subscriber_id: subscriber_id,
                                                                          status: 'pending')
      end
      Success(true)
    rescue StandardError => e
      Rails.logger.error e.message
      Failure("Unable to store or parse response due to #{e.message}")
    end

    def fetch_and_store_coverage_history(audit_report_execution)
      puts "Total number of record for carrier #{audit_report_execution.hios_id} is
            #{audit_report_execution.audit_report_datum.count}"
      counter = 0
      audit_report_execution.audit_report_datum.each do |audit_datum|
        status = Reports::RequestCoverageHistoryForSubscriber.new.call({ audit_report_datum: audit_datum,
                                                                         audit_report_execution: audit_report_execution })

        status.success? ? counter += 1 : counter

        puts "Total number of records updated with coverage information payload #{counter}" if counter % 100 == 0
      end
    end
  end
end
