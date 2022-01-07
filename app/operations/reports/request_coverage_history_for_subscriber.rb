# frozen_string_literal: true

require 'faraday'

module Reports
  # request glue to get coverage history for subscriber
  class RequestCoverageHistoryForSubscriber
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    def call(params)
      valid_params = yield validate(params)
      coverage_history_response = yield fetch_coverage_history(valid_params)
      status = yield store_coverage_history(coverage_history_response, valid_params[:audit_report_datum])
      Success(status)
    end

    private

    def validate(params)
      return Failure("No audit datum record") if params[:audit_report_datum].blank?

      Success(params)
    end

    def fetch_coverage_history(valid_params)
      @logger = Logger.new("#{Rails.root}/log/recon_report.log")
      audit_datum = valid_params[:audit_report_datum]
      hios_id = valid_params[:audit_report_datum].hios_id
      service_uri = valid_params[:service_uri]
      user_token = valid_params[:user_token]

      params = { year: Date.today.year == 2021 ? 2022 : Date.today.year,
                 hios_id: hios_id,
                 user_token: user_token }

      response = Faraday.get("#{service_uri}/#{audit_datum.subscriber_id}", params)
      @logger.info "Response from glue for subscriber #{audit_datum.subscriber_id} payload #{response.body}"
      response.status == 200 ? Success(response.body) : Failure("Unable to fetch coverage history due to #{response.body}")
    end

    def store_coverage_history(coverage_history_response, audit_datum)
      status = audit_datum.update_attributes(payload: coverage_history_response, status: "completed")
      @logger.info "audit status in our db for subscriber #{audit_datum.subscriber_id} - #{audit_datum.status}"
      Success(status)
    end
  end
end
