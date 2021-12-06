# frozen_string_literal: true

require 'csv'

module Reports
  # Store coverage history for a subscriber and publish event to generate report
  class GeneratePreAuditReport
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    def call(params)
      valid_params = yield validate(params)
      audit_datum = yield fetch_audit_report_datum(valid_params)
      generate_report(valid_params[:payload][:carrier_hios_id], audit_datum)
      Success(true)
    end

    private

    def validate(params)
      return Failure("No carrier hios id present") if params[:payload][:carrier_hios_id].blank?

      Success(params)
    end

    def fetch_audit_report_datum(valid_params)
      audit_report_execution = AuditReportExecution.where(hios_id: valid_params[:payload][:carrier_hios_id]).first
      Success(audit_report_execution.audit_report_datum)
    end

    def generate_report(carrier_hios_id, audit_datum)
      file_name = fetch_file_name(carrier_hios_id)
      field_names = fetch_field_names

      CSV.open(file_name, "w", col_sep: "|") do |csv|
        csv << field_names

        audit_datum.each do |audit_data|
          policies = JSON.parse(audit_data.payload)
          policies.each do |policy|
            policy_contract_result = AcaEntities::Contracts::Policies::PolicyContract.new.call(policy)
            next if policy_contract_result.errors.present?

            policy_entity = AcaEntities::Policies::Policy.new(policy_contract_result.to_h)
            policy_entity.enrollees.each do |enrollee|
              enrollee.segments.each do |segment|
                csv << insert_data(policy_entity, segment, enrollee)
              end
            end
          end
        end
      end
    end

    def fetch_file_name(carrier_hios_id)
      "#{Rails.root}/carrier_hios_id_#{carrier_hios_id}.csv"
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength
    def fetch_field_names
      ["Trading Partner ID", "SPOE ID", "Tenant ID", "HIOS_ID", "QHP Lookup Key", "Application Extract Date",
       "Application Extract Time", "Policy Last Maintenance Date", "Policy Last Maintenance Time", "Application ID",
       "Transaction Code Type", "Agent/Broker First Name", "Agent/Broker Middle Name", "Agent/Broker Last Name",
       "Agent/Broker NPN", "Assistor Type Code", "Individual Relationship Code", "Subscriber Indicator",
       "Reserved for Future Use", "Exchange-Assigned Subscriber ID", "Exchange-Assigned Member ID",
       "Issuer-Assigned Member ID", "Issuer-Assigned Subscriber ID", "QI Last Name", "QI First Name", "QI Middle Name",
       "QI Marital Status", "Residential Address Line 1", "Residential Address Line 2", "Residential City Name",
       "Residential State Code", " Residential ZIP Code", "Residential County Code", "Phone Number",
       "Social Security Number (SSN)", "QI Birth Date", "QI Gender", "Tobacco Use Code", "Race Type",
       "Ethnicity", "Language Code – Spoken", "Language Code – Written", "Email Address", "Mailing Address Line 1",
       "Mailing Address Line 2", "Mailing Address City Name", "Mailing Address State Code", "Mailing Address ZIP Code",
       "Custodial Parent Last Name", "Custodial Parent First Name", "Custodial Parent Mailing Address Line 1",
       "Custodial Parent Mailing Address Line 2", "Custodial Parent Mailing Address City",
       "Custodial Parent State Code", "Custodial Parent ZIP Code", "Responsible Person Last Name",
       "Responsible Person First Name", "Responsible Person Mailing Address Line 1",
       "Responsible Person Mailing Address Line 2", "Responsible Person Mailing Address City",
       "Responsible Person State Code", "Responsible Person ZIP Code", "Benefit Start Date", "Benefit End Date",
       "Issuer-Assigned Policy Number", "QHP Identifier", "Confirmation Indicator", "Exchange-Assigned Policy Number",
       "Marketplace-Assigned Segment ID", "Applied APTC Amount", "Applied APTC Effective Date", "Applied APTC End Date",
       "CSR Amount", "CSR Effective Date", "CSR End Date", "Total Premium Amount", "Total Premium Effective Date",
       "Total Premium End Date", "Individual Premium Amount", "Individual Premium Effective Date",
       "Individual Premium End Date", "Total Responsibility Amount", "Total Responsibility Amount Effective Date",
       "Total Responsibility Amount End Date", "End of Year Termination Indicator", "Cancellation Source",
       "Termination Source", "Cancellation Reason", "Overlap Indicator", "Termination Reason", "Rating Area",
       "Paid Through Date", "Payment Transaction ID", "Insurance Application Origin Type", "Insurance Line of Business",
       "CIC Correlation Key", "Agent/Broker Suffix", "Reserved for Future Use", "Reserved for Future Use",
       "New Policy ID Indicator", "Date of Birth Cleanup Indicator", "Missing Outbound 834 Indicator",
       "Outbound 834 Retransmission Indicator", "Outbound 834 Transaction History"]
    end

    def insert_data(policy_entity, segment, enrollee)
      [nil, nil, "ME0", nil, policy_entity.qhp_id, nil, nil,
       policy_entity.last_maintenance_date.strftime("%Y-%m-%d"), policy_entity.last_maintenance_time,
       policy_entity.primary_subscriber&.hbx_member_id, policy_entity.aasm_state, nil, nil, nil, nil, nil,
       enrollee.relationship_status_code, enrollee.is_subscriber, policy_entity.primary_subscriber&.hbx_member_id,
       enrollee.hbx_member_id, enrollee.issuer_assigned_member_id,
       policy_entity.primary_subscriber&.issuer_assigned_member_id, enrollee.last_name, enrollee.first_name,
       enrollee.middle_name, nil, enrollee.residential_address&.address_1, enrollee.residential_address&.address_2,
       enrollee.residential_address&.city, enrollee.residential_address&.state, enrollee.residential_address&.zip,
       enrollee.residential_address&.county, enrollee.enrollee_demographics.ssn,
       enrollee.enrollee_demographics.dob.strftime("%Y-%m-%d"), enrollee.enrollee_demographics.gender_code,
       enrollee.enrollee_demographics.tobacco_use_code, nil, nil, nil, nil, enrollee.mailing_address&.address_1,
       enrollee.mailing_address&.address_2, enrollee.mailing_address&.city, enrollee.mailing_address&.state,
       enrollee.mailing_address&.zip, enrollee.mailing_address&.county, nil, nil, nil, nil, nil, nil, nil,
       policy_entity.responsible_party_subscriber&.last_name, policy_entity.responsible_party_subscriber&.first_name,
       policy_entity.responsible_party_subscriber&.mailing_address&.address_1,
       policy_entity.responsible_party_subscriber&.mailing_address&.address_2,
       policy_entity.responsible_party_subscriber&.mailing_address&.city,
       policy_entity.responsible_party_subscriber&.mailing_address&.state,
       policy_entity.responsible_party_subscriber&.mailing_address&.zip,
       enrollee.coverage_start.strftime("%Y-%m-%d"), enrollee.coverage_end.strftime("%Y-%m-%d"),
       enrollee.issuer_assigned_policy_id, policy_entity.qhp_id, policy_entity.effectuation_status,
       policy_entity.enrollment_group_id, segment.id, segment.aptc_amount,
       segment.effective_start_date.strftime("%Y-%m-%d"), segment.effective_end_date.strftime("%Y-%m-%d"),
       segment.csr_variant, segment.effective_start_date.strftime("%Y-%m-%d"),
       segment.effective_end_date.strftime("%Y-%m-%d"), segment.individual_premium_amount,
       segment.effective_start_date.strftime("%Y-%m-%d"), segment.effective_end_date.strftime("%Y-%m-%d"),
       segment.total_responsible_amount, segment.effective_start_date.strftime("%Y-%m-%d"),
       segment.effective_end_date.strftime("%Y-%m-%d"), nil, nil, policy_entity.term_for_np, nil, nil, nil,
       policy_entity.rating_area, nil, nil, nil, policy_entity.insurance_line_code, nil, nil, nil, nil, nil, nil, nil,
       nil, nil]
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/MethodLength
  end
end