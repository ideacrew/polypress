# frozen_string_literal: true

require 'faraday'

module Reports
  # make an http call to glue to fetch subscriber list and coverage info
  class FetchAndStoreSubscribersAndCoverageHistory
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    def call(params)
      @year = params[:year]
      hios_id = params[:carrier_hios_id]
      service_uri = yield fetch_subscriber_list_end_point
      user_token = yield fetch_user_token
      subscribers_list = yield fetch_subscribers_list(service_uri, user_token, hios_id)
      _status = yield store_subscribers_list(subscribers_list, hios_id)
      fetch_and_store_coverage_history(hios_id)
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

    def fetch_subscribers_list(service_uri, user_token, hios_id)
      params = { year: @year,
                 hios_id: hios_id,
                 user_token: user_token }

      response = Faraday.get(service_uri, params)

      response.status == 200 ? Success(response.body) : Failure("Unable to fetch subscribers list due to #{response.body}")
    end

    def store_subscribers_list(subscribers_json, hios_id)
      parsed_subscriber_list = JSON.parse(subscribers_json)
      parsed_subscriber_list.each do |subscriber_id|
        audit_record = AuditReportDatum.where(subscriber_id: subscriber_id, hios_id: hios_id, year: @year).first
        if audit_record.present?
          audit_record.update_attributes(status: "pending", payload: nil)
          audit_record.policies = []
        else
          AuditReportDatum.create!(subscriber_id: subscriber_id,
                                   status: 'pending',
                                   hios_id: hios_id,
                                   report_type: "pre_audit",
                                   year: @year)
        end
      end
      Success(true)
    rescue StandardError => e
      Rails.logger.error e.message
      Failure("Unable to store or parse response due to #{e.message}")
    end

    def remove_existing_audit_datum(hios_id)
      AuditReportDatum.all.where(hios_id: hios_id).delete_all
    end

    def fetch_and_store_coverage_history(hios_id)
      audit_datum = AuditReportDatum.where(hios_id: hios_id, year: @year)
      puts "Total number of record for carrier #{hios_id} is #{audit_datum.count}"
      audit_datum.each do |audit|
        RequestSubscriberCoverageHistoryJob.perform_later(audit.id.to_s, 0)
      end
    end
  end
end
