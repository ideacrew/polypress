# frozen_string_literal: true

require 'faraday'

module Reports
  # request glue to get coverage history for subscriber
  class RequestCoverageHistoryForSubscriber
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    def call(params)
      valid_params = yield validate(params)
      @logger = valid_params[:logger]
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
      audit_datum = valid_params[:audit_report_datum]
      hios_id = valid_params[:audit_report_datum].hios_id
      service_uri = valid_params[:service_uri]
      user_token = valid_params[:user_token]

      params = { year: audit_datum.year,
                 hios_id: hios_id,
                 user_token: user_token }

      response = Faraday.get("#{service_uri}/#{audit_datum.subscriber_id}", params)
      @logger.info "Response from glue for subscriber #{audit_datum.subscriber_id} payload #{response.body}" if @logger.present?
      response.status == 200 ? Success(response.body) : Failure("Unable to fetch coverage history due to #{response.body}")
    end

    def store_coverage_history(coverage_history_response, audit_datum)
      status = audit_datum.update_attributes(payload: coverage_history_response, status: "completed")
      policies_response = JSON.parse(coverage_history_response)
      policies_response.each do |policy|
        audit_datum.policies << Policy.new(payload: policy.to_json, policy_eg_id: policy["enrollment_group_id"])
      end
      @logger.info "audit status in our db for subscriber #{audit_datum.subscriber_id} - #{audit_datum.status}" if @logger.present?
      Success(status)
    end
  end
end
