# frozen_string_literal: true

require 'csv'

module Reports
  # Store coverage history for a subscriber and publish event to generate report
  # rubocop:disable Metrics/ClassLength
  class GenerateRcnoReport
    send(:include, Dry::Monads[:result, :do])
    send(:include, Dry::Monads[:try])

    def call(params)
      valid_params = yield validate(params)
      audit_datum = yield fetch_audit_report_datum(valid_params)
      @logger = Logger.new("#{Rails.root}/log/rcno_report_errors_for_#{valid_params[:payload][:carrier_hios_id]}")
      rcni_file_path = yield fetch_rcni_file_path(valid_params[:payload][:carrier_hios_id])
      generate_rcno_report(rcni_file_path, valid_params[:payload][:carrier_hios_id], audit_datum)
      Success(true)
    end

    private

    def validate(params)
      parsed_params = JSON.parse(params[:payload]).deep_symbolize_keys!
      return Failure("No carrier hios id present") if parsed_params[:payload][:carrier_hios_id].blank?

      Success(parsed_params)
    end

    def fetch_audit_report_datum(valid_params)
      audit_report_datum = AuditReportDatum.where(hios_id: valid_params[:payload][:carrier_hios_id],
                                                  status: "completed",
                                                  report_type: "RCNO")
      Success(audit_report_datum)
    end

    # rubocop:disable Metrics/MethodLength
    def generate_rcno_report(rcni_file_path, carrier_hios_id, audit_datum)
      file_name = fetch_rcno_file_name(carrier_hios_id)
      @total_number_of_issuer_records = 0
      @total_subscribers = 0
      @total_dependents = 0
      @total_premium_amount = 0.00
      @total_applied_premium_amount = 0.00
      @overall_flag = "M"
      CSV.open(file_name, "w", col_sep: "|") do |csv|
        File.readlines(rcni_file_path, chomp: true).each do |line|
          @rcni_row = line.split("|")

          if @rcni_row[0] == "01"
            @audit_record = audit_datum.where(subscriber_id: @rcni_row[16]).first
            if  @audit_record.blank?
              @logger.info "Unable to find subscriber from given rcni report #{@rcni_row[16]}"
              next
            end
            @policy, @member = fetch_policy_and_member
            csv << insert_data
            @total_number_of_issuer_records += 1
          else
            csv << insert_total_record_data
          end
        end
      rescue StandardError => e
        puts e.backtrace
        @logger.info "Unable to generate report due to #{e.backtrace}"
        Rails.logger.error("Unable to generate report due to #{e}")
      end
    end
    # rubocop:enable Metrics/MethodLength

    def fetch_policy_and_member
      policies = JSON.parse(@audit_record.payload)
      fetched_policy = policies.detect {|policy| policy["enrollment_group_id"] == @rcni_row[20]}
      policy_contract_result = AcaEntities::Contracts::Policies::PolicyContract.new.call(fetched_policy)
      policy_entity = AcaEntities::Policies::Policy.new(policy_contract_result.to_h)

      member = policy_entity.enrollees.detect {|enrollee| enrollee.hbx_member_id == @rcni_row[17]}
      [policy_entity, member]
    end

    def fetch_rcni_file_path(hios_id)
      if File.exist?("#{Rails.root}/RCNI_#{hios_id}.txt")
        Success("#{Rails.root}/RCNI_#{hios_id}.txt")
      else
        Failure("Unable to find rcni file for hios id #{hios_id}")
      end
    end

    def fetch_rcno_file_name(carrier_hios_id)
      "#{Rails.root}/rcno_carrier_hios_id_#{carrier_hios_id}.csv"
    end

    def fetch_relationship_code(code)
      {
        "self" => "18",
        "spouse" => "01",
        "ward" => "15",
        "child" => "19"
      }.stringify_keys[code.to_s]
    end

    def phone_number
      return nil if @member.phones.blank?

      @member.phones.last.full_phone_number
    end

    def tobacco_use_code(tobacco_code)
      case tobacco_code
      when "Y"
        1
      when "N"
        2
      end
    end

    def qhp_id
      "#{@policy.qhp_id}#{@policy.csr_variant}"
    end

    def fetch_applied_aptc_amount
      return 0.00 unless @member.is_subscriber
      return 0.00 if [0.0, 0, 0.00].include?(@policy.applied_aptc)
      @policy.applied_aptc
    end

    def fetch_effectuation_status
      if @policy.effectuation_status == "N" && @policy.aasm_state == "canceled"
        "C"
      else
        @policy.effectuation_status
      end
    end

    def members_count(status)
      if status == "Y"
        @total_subscribers += 1
      else
        @total_dependents += 1
      end
    end

    def compare_first_name
      ffm_first_name = @member.first_name
      issuer_first_name = @rcni_row[8]
      match_data = /#{ffm_first_name}/i.match?(issuer_first_name) ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_first_name, issuer_first_name, match_data]
    end

    def compare_middle_name
      ffm_middle_name = @member.middle_name
      issuer_middle_name = @rcni_row[9]
      return [ffm_middle_name, issuer_middle_name, "D"] if ffm_middle_name.blank? && issuer_middle_name.blank?

      match_data = /#{ffm_middle_name}/i.match?(ffm_middle_name) ? "M" : "D"
      @overall_flag = "N" if match_data == "I"
      [ffm_middle_name, issuer_middle_name, match_data]
    end

    def compare_last_name
      ffm_last_name = @member.last_name
      issuer_last_name = @rcni_row[10]
      match_data = /#{ffm_last_name}/i.match?(issuer_last_name) ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_last_name, issuer_last_name, match_data]
    end

    def compare_dob
      ffm_dob = @member.enrollee_demographics.dob.strftime("%Y%m%d")
      issuer_dob = @rcni_row[11]
      match_data = ffm_dob == issuer_dob ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_dob, issuer_dob, match_data]
    end

    def compare_gender
      ffm_gender = @member.enrollee_demographics.gender_code
      issuer_gender = @rcni_row[12]
      match_data = /#{ffm_gender}/i.match?(issuer_gender) ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_gender, issuer_gender, match_data]
    end

    def compare_ssn
      ffm_ssn = @member.enrollee_demographics.ssn
      issuer_ssn = @rcni_row[13]
      match_data = ffm_ssn == issuer_ssn ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_ssn, issuer_ssn, match_data]
    end

    def subscriber_indicator
      status = @member.is_subscriber ? 'Y' : 'N'
      members_count(status)
      ffm_subscriber_status = status
      issuer_subscriber_status = @rcni_row[14]
      match_data = /#{ffm_subscriber_status}/i.match?(issuer_subscriber_status) ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_subscriber_status, issuer_subscriber_status, match_data]
    end

    def relation_to_subscriber_indicator
      ffm_subscriber_status = fetch_relationship_code(@member.relationship_status_code)
      issuer_subscriber_status = @rcni_row[15]
      match_data = ffm_subscriber_status == issuer_subscriber_status ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_subscriber_status, issuer_subscriber_status, match_data]
    end

    def exchange_assigned_subscriber_id
      ffm_subscriber_id = @policy.primary_subscriber&.hbx_member_id
      issuer_subscriber_id = @rcni_row[16]
      match_data = ffm_subscriber_id == issuer_subscriber_id ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_subscriber_id, issuer_subscriber_id, match_data]
    end

    def exchange_assigned_member_id
      ffm_member_id = @member.hbx_member_id
      issuer_member_id = @rcni_row[17]
      match_data = ffm_member_id == issuer_member_id ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_member_id, issuer_member_id, match_data]
    end

    def issuer_assigned_subscriber_id
      ffm_issuer_subscriber_id = @policy.primary_subscriber&.issuer_assigned_member_id
      issuer_issuer_subscriber_id = @rcni_row[18]
      if issuer_issuer_subscriber_id.blank? && ffm_issuer_subscriber_id.present?
        @overall_flag = "N"
        return [ffm_issuer_subscriber_id, issuer_issuer_subscriber_id, "U"]
      end

      match_data = ffm_issuer_subscriber_id == issuer_issuer_subscriber_id ? "M" : "G"
      @overall_flag = "N" if match_data == "G"
      [ffm_issuer_subscriber_id, issuer_issuer_subscriber_id, match_data]
    end

    def issuer_assigned_member_id
      ffm_issuer_member_id = @member.issuer_assigned_member_id
      issuer_issuer_member_id = @rcni_row[19]
      if issuer_issuer_member_id.blank? && ffm_issuer_member_id.present?
        @overall_flag = "N"
        return [ffm_issuer_member_id, issuer_issuer_member_id, "U"]
      end

      match_data = ffm_issuer_member_id == issuer_issuer_member_id ? "M" : "G"
      @overall_flag = "N" if match_data == "G"
      [ffm_issuer_member_id, issuer_issuer_member_id, match_data]
    end

    def exchange_assigned_policy_number
      ffm_exchange_policy_number = @policy.enrollment_group_id
      issuer_exchange_policy_number = @rcni_row[20]
      match_data = ffm_exchange_policy_number == issuer_exchange_policy_number ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_exchange_policy_number, issuer_exchange_policy_number, match_data]
    end

    def issuer_assigned_policy_number
      ffm_issuer_policy_number = @member.issuer_assigned_policy_id
      issuer_issuer_policy_number = @rcni_row[21]
      if issuer_issuer_policy_number.blank? && ffm_issuer_policy_number.present?
        @overall_flag = "N"
        return [ffm_issuer_policy_number, issuer_issuer_policy_number, "U"]
      end

      match_data = ffm_issuer_policy_number == issuer_issuer_policy_number ? "M" : "G"
      @overall_flag = "N" if match_data == "G"
      [ffm_issuer_policy_number, issuer_issuer_policy_number, match_data]
    end

    def qhp_id_match
      ffm_qhp_id = qhp_id
      issuer_qhp_id = @rcni_row[36]
      match_data = ffm_qhp_id == issuer_qhp_id ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_qhp_id, issuer_qhp_id, match_data]
    end

    def benefit_start_date
      ffm_benefit_start = @member.coverage_start.strftime("%Y%m%d")
      issuer_benefit_start = @rcni_row[37]
      match_data = ffm_benefit_start == issuer_benefit_start ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_benefit_start, issuer_benefit_start, match_data]
    end

    def benefit_end_date
      ffm_benefit_end = @member.coverage_end.strftime("%Y%m%d")
      issuer_benefit_end = @rcni_row[38]
      if issuer_benefit_end.blank?
        @overall_flag = "N"
        return [ffm_benefit_end, issuer_benefit_end, "G"]
      end

      match_data = ffm_benefit_end == issuer_benefit_end ? "M" : "G"
      @overall_flag = "N" if match_data == "G"
      [ffm_benefit_end, issuer_benefit_end, match_data]
    end

    def applied_aptc_value
      return ["0.00", @rcni_row[39], "D"] unless @member.is_subscriber

      @total_applied_premium_amount += fetch_applied_aptc_amount
      ffm_applied_aptc_amount = format('%.2f', fetch_applied_aptc_amount)
      issuer_applied_aptc_amount = @rcni_row[39]
      match_data = ffm_applied_aptc_amount == issuer_applied_aptc_amount ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_applied_aptc_amount, issuer_applied_aptc_amount, match_data]
    end

    def applied_aptc_start_date
      ffm_applied_aptc_start_date = @member.coverage_start.strftime("%Y%m%d")
      issuer_applied_start_date = @rcni_row[40]
      return [nil, issuer_applied_start_date, "D"] unless @member.is_subscriber

      match_data = ffm_applied_aptc_start_date == issuer_applied_start_date ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_applied_aptc_start_date, issuer_applied_start_date, match_data]
    end

    def applied_aptc_end_date
      ffm_applied_aptc_end_date = @member.coverage_end.strftime("%Y%m%d")
      issuer_applied_end_date = @rcni_row[41]
      return [nil, issuer_applied_end_date, "D"] unless @member.is_subscriber

      match_data = ffm_applied_aptc_end_date == issuer_applied_end_date ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_applied_aptc_end_date, issuer_applied_end_date, match_data]
    end

    def total_premium_amount
      return ["0.00", @rcni_row[45],  "D"] unless @member.is_subscriber

      @total_premium_amount += @policy.total_premium_amount
      ffm_total_premium = format('%.2f', @policy.total_premium_amount)
      issuer_total_premium = @rcni_row[45]
      match_data = ffm_total_premium == issuer_total_premium ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_total_premium, issuer_total_premium, match_data]
    end

    def total_premium_start_date
      ffm_total_premium_start = @member.coverage_start.strftime("%Y%m%d")
      issuer_total_premium_start = @rcni_row[46]
      match_data = ffm_total_premium_start == issuer_total_premium_start ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_total_premium_start, issuer_total_premium_start, match_data]
    end

    def total_premium_end_date
      ffm_total_premium_end = @member.coverage_end.strftime("%Y%m%d")
      issuer_total_premium_end = @rcni_row[47]
      match_data = ffm_total_premium_end == issuer_total_premium_end ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_total_premium_end, issuer_total_premium_end, match_data]
    end

    def individual_premium_amount
      ffm_individual_premium = format('%.2f', @member.premium_amount)
      issuer_premium_mount = @rcni_row[48]
      return [ffm_individual_premium, issuer_premium_mount, "D"] if ["N", "C"].include?(@policy.effectuation_status)

      match_data = ffm_individual_premium == issuer_premium_mount ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_individual_premium, issuer_premium_mount, match_data]
    end

    def individual_premium_start_date
      ffm_individual_premium_start_date =  @member.coverage_start.strftime("%Y%m%d")
      issuer_individual_premium_start_date = @rcni_row[49]
      return [ffm_individual_premium_start_date, issuer_individual_premium_start_date, "D"] if ["N", "C"].include?(@policy.effectuation_status)

      match_data = ffm_individual_premium_start_date == issuer_individual_premium_start_date ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_individual_premium_start_date, issuer_individual_premium_start_date, match_data]
    end

    def individual_premium_end_date
      ffm_individual_premium_end_date =  @member.coverage_end.strftime("%Y%m%d")
      issuer_individual_premium_end_date = @rcni_row[50]
      return [ffm_individual_premium_end_date, issuer_individual_premium_end_date, "D"] if ["N", "C"].include?(@policy.effectuation_status)

      match_data = ffm_individual_premium_end_date == issuer_individual_premium_end_date ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_individual_premium_end_date, issuer_individual_premium_end_date, match_data]
    end

    def premium_paid_status
      ffm_premium_status = fetch_effectuation_status
      issuer_premium_status = @rcni_row[51]
      match_data = ffm_premium_status == issuer_premium_status ? "M" : "G"
      @overall_flag = "N" if match_data == "G"
      [ffm_premium_status, issuer_premium_status, match_data]
    end

    def coverage_year
      ffm_coverage_year = @policy.primary_subscriber.coverage_start.year.to_s
      issuer_coverage_year = @rcni_row[53]
      match_data = ffm_coverage_year == issuer_coverage_year ? "M" : "I"
      @overall_flag = "N" if match_data == "I"
      [ffm_coverage_year, issuer_coverage_year, match_data]
    end

    def market_place_segment_id
      subscriber = @policy.primary_subscriber
      date = subscriber.coverage_start.strftime("%Y%m%d")
      "#{subscriber.hbx_member_id}-#{@policy.enrollment_group_id}-#{date}"
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    def insert_data
      first_name = compare_first_name
      middle_name = compare_middle_name
      last_name = compare_last_name
      dob = compare_dob
      gender = compare_gender
      ssn = compare_ssn
      sub_indicator = subscriber_indicator
      rel_to_sub_indicator = relation_to_subscriber_indicator
      exh_assigned_sub_id = exchange_assigned_subscriber_id
      exh_assigned_mem_id = exchange_assigned_member_id
      issuer_assigned_sub_id = issuer_assigned_subscriber_id
      issuer_assigned_mem_id = issuer_assigned_member_id
      exh_assigned_policy_id = exchange_assigned_policy_number
      issuer_assigned_policy_id = issuer_assigned_policy_number
      applied_aptc_amount = applied_aptc_value
      all_policy_total_premium_amount = total_premium_amount

      [@rcni_row[0], @rcni_row[1], @rcni_row[2], @rcni_row[3], @rcni_row[4], @rcni_row[5], @rcni_row[6],
       first_name[0], first_name[1], first_name[2],
       middle_name[0], middle_name[1], middle_name[2],
       last_name[0], last_name[1], last_name[2],
       dob[0], dob[1], dob[2],
       gender[0], gender[1], gender[2],
       ssn[0], ssn[1], ssn[2],
       sub_indicator[0], sub_indicator[1], sub_indicator[2],
       rel_to_sub_indicator[0], rel_to_sub_indicator[1], rel_to_sub_indicator[2],
       exh_assigned_sub_id[0], exh_assigned_sub_id[1], exh_assigned_sub_id[2],
       exh_assigned_mem_id[0], exh_assigned_mem_id[1], exh_assigned_mem_id[2],
       issuer_assigned_sub_id[0], issuer_assigned_sub_id[1], issuer_assigned_sub_id[2],
       issuer_assigned_mem_id[0], issuer_assigned_mem_id[1], issuer_assigned_mem_id[2],
       exh_assigned_policy_id[0], exh_assigned_policy_id[1], exh_assigned_policy_id[2],
       issuer_assigned_policy_id[0], issuer_assigned_policy_id[1], issuer_assigned_policy_id[2],
       @member.residential_address&.address_1, @rcni_row[22], 'D',
       @member.residential_address&.address_2, @rcni_row[23], 'D',
       @member.residential_address&.city, @rcni_row[24], 'D',
       @member.residential_address&.state, @rcni_row[25],  'D',
       @member.residential_address&.zip, @rcni_row[26], 'D',
       @member.mailing_address&.address_1, @rcni_row[27],  'D',
       @member.mailing_address&.address_2, @rcni_row[28],  'D',
       @member.mailing_address&.city, @rcni_row[29],  'D',
       @member.mailing_address&.state, @rcni_row[30],  'D',
       @member.mailing_address&.zip, @rcni_row[31], 'D',
       @member.residential_address&.county, @rcni_row[32], 'D',
       @policy.rating_area, @rcni_row[33], 'D',
       phone_number, @rcni_row[34],  'D',
       tobacco_use_code(@member.enrollee_demographics.tobacco_use_code), @rcni_row[35], 'D',
       qhp_id_match[0], qhp_id_match[1], qhp_id_match[2],
       benefit_start_date[0], benefit_start_date[1], benefit_start_date[2],
       benefit_end_date[0], benefit_end_date[1], benefit_end_date[2],

       applied_aptc_amount[0], applied_aptc_amount[1], applied_aptc_amount[2],
       applied_aptc_start_date[0], applied_aptc_start_date[1], applied_aptc_start_date[2],
       applied_aptc_end_date[0], applied_aptc_end_date[1], applied_aptc_end_date[2],

       nil, @rcni_row[42],  "D",
       applied_aptc_start_date[0], @rcni_row[43], "D",
       applied_aptc_end_date[0], @rcni_row[44],  "D",

       all_policy_total_premium_amount[0], all_policy_total_premium_amount[1], all_policy_total_premium_amount[2],
       total_premium_start_date[0], total_premium_start_date[1], total_premium_start_date[2],
       total_premium_end_date[0], total_premium_end_date[1], total_premium_end_date[2],

       individual_premium_amount[0], individual_premium_amount[1], individual_premium_amount[2],
       individual_premium_start_date[0], individual_premium_start_date[1], individual_premium_start_date[2],
       individual_premium_end_date[0], individual_premium_end_date[1], individual_premium_end_date[2],
       premium_paid_status[0], premium_paid_status[1], premium_paid_status[2],
       @overall_flag, @rcni_row[52], "D",
       nil, nil, nil,
       coverage_year[0], coverage_year[1], coverage_year[2],
       nil, @rcni_row[54], "D",
       nil, @rcni_row[55], "D",
       nil, @rcni_row[56], "D",
       nil, @rcni_row[57], "D",
       nil, @rcni_row[58], "D",
       nil, @rcni_row[59], "D",
       nil, @rcni_row[60], "D",
       nil, nil, nil,
       nil, @rcni_row[61], "D",
       nil, @rcni_row[62], "D",
       market_place_segment_id, nil, nil]
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength

    def insert_total_record_data
      [@rcni_row[0], @rcni_row[1], @rcni_row[2], @rcni_row[3], @rcni_row[4], @rcni_row[5], @total_number_of_issuer_records,
       @total_subscribers, @total_dependents,  format('%.2f', @total_premium_amount),
       format('%.2f', @total_applied_premium_amount)]
    end
  end
  # rubocop:enable Metrics/ClassLength
end