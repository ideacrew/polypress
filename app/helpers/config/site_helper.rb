# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module Config
  # Site wide helpers
  # TODO: Everything in this with Settings.site should be configured into ResourceRegistry files eventually
  module SiteHelper
    def statewide_area
      PolypressRegistry[:enroll_app].setting(:statewide_area).item
    end

    def site_state_abbreviation
      PolypressRegistry[:enroll_app].setting(:state_abbreviation).item
    end

    def site_short_url
      PolypressRegistry[:enroll_app].setting(:short_url).item
    end

    def site_privacy_url
      PolypressRegistry[:enroll_app].setting(:privacy_url).item
    end

    def site_privacy_act_statement
      PolypressRegistry[:enroll_app].setting(:privacy_act_statement).item
    end

    def site_po_box
      PolypressRegistry[:enroll_app].setting(:contact_center_po_box).item
    end

    def site_state_long_title
      PolypressRegistry[:enroll_app].setting(:state_long_title).item
    end

    def contact_center_state_and_city
      PolypressRegistry[:enroll_app].setting(:contact_center_state_and_city).item
    end

    def contact_center_zip_code
      PolypressRegistry[:enroll_app].setting(:contact_center_zip_code).item
    end

    def contact_center_short_phone_number
      PolypressRegistry[:enroll_app].setting(:contact_center_short_number).item
    end

    def health_benefit_exchange_authority_phone_number
      PolypressRegistry[:enroll_app].setting(:health_benefit_exchange_authority_phone_number).item
    end

    def site_mailer_logo_file_name
      PolypressRegistry[:enroll_app].setting(:mailer_logo_file_name).item
    end

    def site_producer_email_address
      PolypressRegistry[:enroll_app].setting(:producer_email_address).item
    end

    def contact_center_email_address
      PolypressRegistry[:enroll_app].setting(:contact_center_email_address).item
    end

    def site_redirect_on_timeout_route
      Settings.site.curam_enabled? ? SamlInformation.iam_login_url : new_user_session_path
    end

    def site_byline
      PolypressRegistry[:enroll_app].setting(:byline).item
    end

    def site_key
      PolypressRegistry[:enroll_app].settings(:site_key).item
    end

    def site_domain_name
      PolypressRegistry[:enroll_app].setting(:domain_name).item
    end

    def site_website_name
      PolypressRegistry[:enroll_app].setting(:website_name).item
    end

    def site_privacy_policy
      PolypressRegistry[:enroll_app].setting(:privacy_policy).item
    end

    def site_website_link
      link_to site_website_name, site_website_name
    end

    def site_find_expert_link
      link_to site_find_expert_url, site_find_expert_url
    end

    def site_find_expert_url
      "#{site_home_url}/find-expert"
    end

    def site_home_business_url
      PolypressRegistry[:enroll_app].setting(:home_business_url).item
    end

    def site_home_url
      PolypressRegistry[:enroll_app].setting(:home_url).item
    end

    def site_curam_enabled?
      PolypressRegistry[:enroll_app].setting(:curam_enabled).item
    end

    def site_brokers_agreement_path
      link_to(
        "#{Settings.aca.state_name} #{PolypressRegistry[:enroll_app].setting(:short_name).item} Broker Agreement",
        PolypressRegistry[:enroll_app].setting(:terms_and_conditions_url).item
      )
    end

    def site_home_link
      link_to site_home_url, site_home_url
    end

    def site_copyright_period_start
      PolypressRegistry[:enroll_app].setting(:copyright_period_start).item
    end

    def site_name
      PolypressRegistry[:enroll_app].setting(:application_name).item
    end

    def site_help_url
      PolypressRegistry[:enroll_app].setting(:help_url).item
    end

    def site_business_resource_center_url
      PolypressRegistry[:enroll_app].setting(:business_resource_center_url).item
    end

    def marketplace_shopping_name
      PolypressRegistry[:enroll_app].setting(:marketplace_shopping_name).item
    end

    def link_to_site_business_resource_center
      link_to "Business Resource Center", site_business_resource_center_url
    end

    def site_nondiscrimination_notice_url
      PolypressRegistry[:enroll_app].setting(:nondiscrimination_notice_url).item
    end

    def site_policies_url
      PolypressRegistry[:enroll_app].setting(:policies_url).item
    end

    def site_faqs_url
      PolypressRegistry[:enroll_app].setting(:faqs_url).item
    end

    def site_short_name
      PolypressRegistry[:enroll_app].setting(:short_name).item
    end

    def site_producer_advisory_committee_url
      PolypressRegistry[:enroll_app].setting(:producer_advisory_committee_url).item
    end

    def site_broker_registration_url
      PolypressRegistry[:enroll_app].setting(:broker_registration_path).item
    end

    def site_broker_registration_guide
      PolypressRegistry[:enroll_app].setting(:broker_registration_guide).item
    end

    def site_registration_path(resource_name, params)
      if PolypressRegistry[:enroll_app].setting(:registration_path).item.present? && ENV['AWS_ENV'] == 'prod'
        PolypressRegistry[:enroll_app].setting(:registration_path).item
      else
        new_registration_path(resource_name, :invitation_id => params[:invitation_id])
      end
    end

    def site_long_name
      PolypressRegistry[:enroll_app].setting(:long_name).item
    end

    def site_exchange_name
      PolypressRegistry[:enroll_app].setting(:exchange_name).item
    end

    def site_broker_quoting_enabled?
      PolypressRegistry[:enroll_app].setting(:broker_quoting_enabled).item
    end

    def site_main_web_address
      PolypressRegistry[:enroll_app].setting(:main_web_address).item
    end

    def site_main_web_address_url
      PolypressRegistry[:enroll_app].setting(:main_web_address_url).item
    end

    def site_main_web_link
      link_to site_website_name, site_main_web_address_url
    end

    def site_make_their_premium_payments_online
      PolypressRegistry[:enroll_app].setting(:make_their_premium_payments_online).item
    end

    def link_to_make_their_premium_payments_online
      link_to "make your premium payments online", site_make_their_premium_payments_online
    end

    def health_care_website
      PolypressRegistry[:enroll_app].setting(:health_care_website).item
    end

    def site_website_url
      PolypressRegistry[:enroll_app].setting(:website_url).item
    end

    def health_care_website_url
      PolypressRegistry[:enroll_app].setting(:health_care_website_url).item
    end

    def ivl_login_url
      Settings.site.ivl_login_url
    end

    def site_uses_default_devise_path?
      PolypressRegistry[:enroll_app].setting(:use_default_devise_path).item
    end

    def find_your_doctor_url
      Settings.site.shop_find_your_doctor_url
    end

    def site_main_web_address_text
      Settings.site.main_web_address_text
    end

    def site_website_address
      link_to site_website_name, site_main_web_address_url
    end

    def non_discrimination_notice_url
      link_to site_nondiscrimination_notice_url, site_nondiscrimination_notice_url
    end

    def mail_non_discrimination_email
      mail_to non_discrimination_email, non_discrimination_email
    end

    def site_noreply_email_address
      PolypressRegistry[:enroll_app].setting(:no_reply_email).item
    end

    def site_broker_attestation_link
      PolypressRegistry[:enroll_app].setting(:site_broker_attestation_link).item
    end

    def site_employer_application_deadline_link
      PolypressRegistry[:enroll_app].setting(:employer_application_deadline_link).item
    end

    def site_initial_earliest_start_prior_to_effective_on
      Settings.aca.shop_market.initial_application.earliest_start_prior_to_effective_on.months.abs
    end

    def publish_due_day_of_month
      Settings.aca.shop_market.initial_application.publish_due_day_of_month
    end

    def site_guidance_for_business_owners_url
      PolypressRegistry[:enroll_app].setting(:guidance_for_business_owners_url).item
    end

    def site_non_discrimination_complaint_url
      link_to non_discrimination_complaint_url, non_discrimination_complaint_url
    end

    def site_document_verification_checklist_url
      PolypressRegistry[:enroll_app].setting(:document_verification_checklist_url).item
    end

    def site_invoice_bill_url
      PolypressRegistry[:enroll_app].setting(:invoice_bill_url).item
    end

    def medicaid_agency_name
      PolypressRegistry[:enroll_app].setting(:medicaid_agency_name).item
    end

    def medicaid_agency_phone
      PolypressRegistry[:enroll_app].setting(:medicaid_agency_phone).item
    end

    def medicaid_agency_chip_long_name
      PolypressRegistry[:enroll_app].setting(:medicaid_agency_chip_long_name).item
    end

    def medicaid_agency_chip_short_name
      PolypressRegistry[:enroll_app].setting(:medicaid_agency_chip_short_name).item
    end

    def medicaid_agency_program_name
      PolypressRegistry[:enroll_app].setting(:medicaid_agency_program_name).item
    end


    def site_user_sign_in_url
      PolypressRegistry[:enroll_app].setting(:user_sign_in_url).item
    end

    def mail_address
      PolypressRegistry[:enroll_app].setting(:mail_address).item
    end

    def certification_url
      PolypressRegistry[:enroll_app].setting(:certification_url).item
    end

    def site_title
      PolypressRegistry[:enroll_app].setting(:site_title).item
    end

    def fte_max_count
      Settings.aca.shop_market.small_market_employee_count_maximum
    end

    def site_tufts_url
      Settings.site.tufts_premier_url
    end

    def site_tufts_premier_link
      link_to site_tufts_url, site_tufts_url
    end

    def broker_course_administering_organization_number
      PolypressRegistry[:enroll_app].setting(:broker_course_administering_organization_number).item
    end

    def broker_course_administering_organization
      PolypressRegistry[:enroll_app].setting(:broker_course_administering_organization).item
    end

    def broker_course_administering_organization_link
      PolypressRegistry[:enroll_app].setting(:broker_course_administering_organization_link).item
    end
  end
end
# rubocop:enable Metrics/ModuleLength

