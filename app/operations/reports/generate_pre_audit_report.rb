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
      audit_report_execution = AuditReportExecution.where(hios_id: valid_params[:payload][:carrier_hios_id]).last
      Success(audit_report_execution.audit_report_datum)
    end

    def generate_report(carrier_hios_id, audit_datum)
      file_name = fetch_file_name(carrier_hios_id)
      field_names = fetch_field_names

      CSV.open(file_name, "w", col_sep: "|") do |csv|
        csv << field_names

        audit_datum.where(status: "completed").each do |audit_data|
          policies = JSON.parse(audit_data.payload)
          policies.each do |policy|
            policy_contract_result = AcaEntities::Contracts::Policies::PolicyContract.new.call(policy)
            next if policy_contract_result.errors.present?

            policy_entity = AcaEntities::Policies::Policy.new(policy_contract_result.to_h)
            policy_entity.enrollees.each do |enrollee|
              enrollee.segments.each do |segment|
                csv << insert_data(carrier_hios_id, policy_entity, segment, enrollee)
              end
            end
          end
        rescue StandardError => e
          Rails.logger.error("Unable to generate report due to #{e}")
        end
      end
    end

    def fetch_relationship_code(code)
      {
        "self" => "1:83",
        "spouse" => "2:01",
        "ward" => "32:15",
        "child" => "4:19"
      }.stringify_keys[code.to_s]
    end

    def aptc_amount(enrollee, segment)
      return nil unless enrollee.is_subscriber
      return nil if [0.0, 0, 0.00].include?(segment.aptc_amount)

      format('%.2f', segment.aptc_amount)
    end

    def effective_start_date(enrollee, segment)
      return nil unless enrollee.is_subscriber

      segment.effective_start_date&.strftime("%Y%m%d")
    end

    def effective_end_date(enrollee, segment)
      return nil unless enrollee.is_subscriber

      segment.effective_end_date&.strftime("%Y%m%d")
    end

    def csr_variant(enrollee, segment)
      return nil unless enrollee.is_subscriber

      segment.csr_variant
    end

    def total_premium_amount(enrollee, segment)
      return nil unless enrollee.is_subscriber

      format('%.2f', segment.total_premium_amount)
    end

    def total_responsible_amount(enrollee, segment)
      return nil unless enrollee.is_subscriber

      format('%.2f', segment.total_responsible_amount)
    end

    def phone_number(enrollee)
      return nil if enrollee.phones.blank?

      enrollee.phones.last.full_phone_number
    end

    def email_address(enrollee)
      return nil if enrollee.emails.blank?

      enrollee.emails.last.address
    end

    def transaction_code_type(aasm_state)
      if %w[submitted effectuated hbx_terminated hbx_terminated].include?(aasm_state)
        1
      else
        3
      end
    end

    def tobacco_use_code(tobacco_code)
      case tobacco_code
      when "Y"
        1
      when "N"
        2
      end
    end

    def qhp_id(policy_entity)
      "#{policy_entity.qhp_id}0#{policy_entity.csr_variant}"
    end

    def fetch_file_name(carrier_hios_id)
      "#{Rails.root}/carrier_hios_id_#{carrier_hios_id}.csv"
    end

    def segment_id(id)
      result = id.split("-")
      result.delete_at(2)
      result.join("-")
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

    def insert_data(carrier_hios_id, policy_entity, segment, enrollee)
      [carrier_hios_id, nil, "ME0", carrier_hios_id, policy_entity.qhp_id[0, 10], Date.today.strftime("%Y%m%d"),
       DateTime.now.strftime("%H%M%S%L"),
       policy_entity.last_maintenance_date.strftime("%Y%m%d"), policy_entity.last_maintenance_time,
       policy_entity.primary_subscriber&.hbx_member_id, transaction_code_type(policy_entity.aasm_state), nil, nil,
       nil, nil, nil,
       fetch_relationship_code(enrollee.relationship_status_code), enrollee.is_subscriber ? 'Y' : 'N', nil,
       policy_entity.primary_subscriber&.hbx_member_id,
       enrollee.hbx_member_id, enrollee.issuer_assigned_member_id,
       policy_entity.primary_subscriber&.issuer_assigned_member_id, enrollee.last_name, enrollee.first_name,
       enrollee.middle_name, nil, enrollee.residential_address&.address_1, enrollee.residential_address&.address_2,
       enrollee.residential_address&.city, enrollee.residential_address&.state, enrollee.residential_address&.zip,
       enrollee.residential_address&.county, phone_number(enrollee), enrollee.enrollee_demographics&.ssn,
       enrollee.enrollee_demographics&.dob&.strftime("%Y%m%d"), enrollee.enrollee_demographics.gender_code,
       tobacco_use_code(enrollee.enrollee_demographics.tobacco_use_code), nil, nil, nil, nil, email_address(enrollee),
       enrollee.mailing_address&.address_1,
       enrollee.mailing_address&.address_2, enrollee.mailing_address&.city, enrollee.mailing_address&.state,
       enrollee.mailing_address&.zip, nil, nil, nil, nil, nil, nil, nil,
       policy_entity.responsible_party_subscriber&.last_name, policy_entity.responsible_party_subscriber&.first_name,
       policy_entity.responsible_party_subscriber&.mailing_address&.address_1,
       policy_entity.responsible_party_subscriber&.mailing_address&.address_2,
       policy_entity.responsible_party_subscriber&.mailing_address&.city,
       policy_entity.responsible_party_subscriber&.mailing_address&.state,
       policy_entity.responsible_party_subscriber&.mailing_address&.zip,
       enrollee.coverage_start.strftime("%Y%m%d"), enrollee.coverage_end.strftime("%Y%m%d"),
       enrollee.issuer_assigned_policy_id, qhp_id(policy_entity), policy_entity.effectuation_status,
       policy_entity.enrollment_group_id, segment_id(segment.id), aptc_amount(enrollee, segment),
       effective_start_date(enrollee, segment), effective_end_date(enrollee, segment),
       nil, effective_start_date(enrollee, segment),
       effective_end_date(enrollee, segment), total_premium_amount(enrollee, segment),
       nil, nil, format('%.2f', segment.individual_premium_amount),
       segment.effective_start_date.strftime("%Y%m%d"), segment.effective_end_date.strftime("%Y%m%d"),
       total_responsible_amount(enrollee, segment), segment.effective_start_date.strftime("%Y%m%d"),
       segment.effective_end_date.strftime("%Y%m%d"), nil, nil, nil, nil, nil,  policy_entity.term_for_np ? 6 : nil,
       policy_entity.rating_area, nil, nil, nil, policy_entity.insurance_line_code, nil, nil, nil, nil, nil, nil, nil,
       nil, nil]
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/MethodLength
  end
end