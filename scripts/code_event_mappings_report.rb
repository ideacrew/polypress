# frozen_string_literal: true

# Below is how to run this script to verify the code to event mappings for the notices in Production.
#   1. For DC:
#     bundle exec rails r scripts/code_event_mappings_report.rb 'dc'
#   2. For ME:
#     bundle exec rails r scripts/code_event_mappings_report.rb 'me'

# 1. We need to update the DC_CODE_EVENT_MAPPING and/or ME_CODE_EVENT_MAPPING in this script as we create/update notices in Production.
# 2. Below is the script(from lines 15 through 19) that needs to be run in the Production
#    rails console to get the latest correct mappings for the notices.
# 3. And update the DC_CODE_EVENT_MAPPING and/or ME_CODE_EVENT_MAPPING in this script file with the output from the rails console.
# NOTE: Assuming that Production is the source of truth for the notices code to event mapping.

# code_event_mapping = Templates::TemplateModel.all.inject({}) do |result_hash, template_model|
#   result_hash[template_model.print_code] = template_model.subscriber&.event_name
#   result_hash
# end
# code_event_mapping

# District of Columbia
DC_CODE_EVENT_MAPPING = {
  "IVL_ENR" => "enroll.individual.enrollments.submitted",
  "IVL_ERA" => "magi_medicaid.mitc.eligibilities.determined_aptc_eligible",
  "IVL_ERM" => "magi_medicaid.mitc.eligibilities.determined_magi_medicaid_eligible",
  "IVL_ERU" => "magi_medicaid.mitc.eligibilities.determined_uqhp_eligible",
  "IVL_DR0" => "enroll.individual.notices.verifications_reminder",
  "IVL_DR1" => "enroll.individual.notices.first_verifications_reminder",
  "IVL_DR2" => "enroll.individual.notices.second_verifications_reminder",
  "IVL_DR3" => "enroll.individual.notices.third_verifications_reminder",
  "IVL_DR4" => "enroll.individual.notices.fourth_verifications_reminder",
  "IVL_OEM" => "enroll.applications.aptc_csr_credits.renewals.notice.determined_magi_medicaid_eligible",
  "IVL_OEA" => "enroll.applications.aptc_csr_credits.renewals.notice.determined_aptc_eligible",
  "IVL_OEU" => "enroll.applications.aptc_csr_credits.renewals.notice.determined_uqhp_eligible",
  "IVL_FRE" => "enroll.individual.notices.final_renewal_eligibility_determined"
}.freeze

# Maine
ME_CODE_EVENT_MAPPING = {
  "IVLMWE" => "enroll.individual.notices.account_created",
  "IVLERQ" => nil,
  "IVLOEA" => "enroll.applications.aptc_csr_credits.renewals.notice.determined_aptc_eligible",
  "IVLOEM" => "enroll.applications.aptc_csr_credits.renewals.notice.determined_magi_medicaid_eligible",
  "IVLOEQ" => "enroll.individual.notices.qhp_eligible_on_reverification",
  "IVLOEU" => "enroll.applications.aptc_csr_credits.renewals.notice.determined_uqhp_eligible",
  "IVLOEG" => "enroll.individual.notices.expired_consent_during_reverification",
  "IVLMAT" => "enroll.individual.notices.account_transferred",
  "IVLFRE" => "enroll.individual.notices.final_renewal_eligibility_determined",
  "IVLDR0" => "enroll.individual.notices.verifications_reminder",
  "IVLDR1" => "enroll.individual.notices.first_verifications_reminder",
  "IVLDR2" => "enroll.individual.notices.second_verifications_reminder",
  "IVLDR3" => "enroll.individual.notices.third_verifications_reminder",
  "IVLDR4" => "enroll.individual.notices.fourth_verifications_reminder",
  "IVLENR" => "enroll.individual.enrollments.submitted",
  "IVLCAP" => "edi_gateway.families.tax_form1095a.catastrophic_payload_generated",
  "IVLVTA" => "fdsh_gateway.irs1095as.void_notice_requested",
  "IVLTAX" => "fdsh_gateway.irs1095as.initial_notice_requested",
  "IVLTXC" => "fdsh_gateway.irs1095as.corrected_notice_requested",
  "IVLERM" => "magi_medicaid.mitc.eligibilities.determined_magi_medicaid_eligible",
  "IVLERA" => "magi_medicaid.mitc.eligibilities.determined_aptc_eligible",
  "IVLERU" => "magi_medicaid.mitc.eligibilities.determined_uqhp_eligible",
  "IVLNEL" => "enroll.families.notices.faa_totally_ineligible_notice.requested"
}.freeze

def event_name_to_ui_option_mapping
  ::Templates::TemplateModel.first.publisher_options.invert
end

# rubocop:disable Metrics/MethodLength
def verify_code_event_mappings(client_code_event_mapping, event_name_to_ui_option_mapping)
  missing_mappings_for_codes = []
  incorrect_mappings_for_codes = []
  correct_mappings_for_codes = []
  client_code_event_mapping.each_key do |print_code|
    template_model = ::Templates::TemplateModel.where(print_code: print_code).first

    if template_model.blank?
      # Template Model is missing.
      p "#{print_code} - Template Model is missing for the print_code"
      missing_mappings_for_codes << print_code
      next print_code
    end

    event_name = template_model.subscriber&.event_name
    if event_name.blank?
      # Event Name(and/or Subscriber) is missing.
      p "#{print_code} - Subscriber and/or Event Name is missing for Template Model with the print_code"
      missing_mappings_for_codes << print_code
      next print_code
    end

    prod_event_name = client_code_event_mapping[print_code]
    if prod_event_name != event_name
      incorrect_mappings_for_codes << print_code
      option_to_be_selected = event_name_to_ui_option_mapping[prod_event_name]
      if option_to_be_selected.present?
        p "#{print_code} - Incorrect mapping for the print_code. Prod has '#{
          prod_event_name}' but the current environment has '#{
            event_name}'. Please select '#{option_to_be_selected}' in the UI dropdown to fix this issue."
      else
        p "#{print_code} - Incorrect mapping for the print_code. Prod has '#{
          prod_event_name}' but the current environment has '#{
            event_name}'. There is no mapping in the UI dropdown."
      end
    end

    correct_mappings_for_codes << print_code
  end

  p "Overall missing mappings for print_codes: #{missing_mappings_for_codes.join(', ')}"
  p "Overall incorrect mappings for print_codes: #{incorrect_mappings_for_codes.join(', ')}"
  p "Overall correct mappings for print_codes: #{correct_mappings_for_codes.join(', ')}"
  nil
end
# rubocop:enable Metrics/MethodLength

client_code_event_mapping = ARGV[0].present? && ARGV[0].to_s.downcase == 'dc' ? DC_CODE_EVENT_MAPPING : ME_CODE_EVENT_MAPPING
verify_code_event_mappings(client_code_event_mapping, event_name_to_ui_option_mapping)
