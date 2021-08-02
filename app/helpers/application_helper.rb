# frozen_string_literal: true

# Application Helper
module ApplicationHelper

  def prepend_glyph_to_text(template)
    if template.key
      "<i class='fa fa-link' data-toggle='tooltip' title='#{template.key}'></i>&nbsp;&nbsp;&nbsp;&nbsp;#{path_for_notice_preview(template)}".html_safe
    else
      "<i class='fa fa-link' data-toggle='tooltip' style='color: silver'></i>&nbsp;&nbsp;&nbsp;&nbsp;#{path_for_notice_preview(template)}".html_safe
    end
  end

  def path_for_notice_preview(template)
    link_to template.subject, preview_template_path(template), target: '_blank'
  end

  def individual_market(_recipient)
    true
  end

  def check_for_insert(insert, template)
    return false unless template.persisted? || template.inserts.present?

    template.inserts.include? insert.key.to_s
  end

  def asset_data_base64(path)
    asset = ::Sprockets::Railtie.build_environment(Rails.application).find_asset(path)
    throw "Could not find asset '#{path}'" if asset.nil?
    base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
    "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
  end

  def shop_market(_recipient)
    false
  end

  def render_flash
    rendered = []
    flash.each do |type, messages|
      if messages.respond_to?(:each)
        messages.each do |m|
          rendered << render(:partial => 'layouts/flash', :locals => { :type => type, :message => m }) unless m.blank?
        end
      else
        rendered << render(:partial => 'layouts/flash', :locals => { :type => type, :message => messages }) unless messages.blank?
      end
    end
    rendered.join.html_safe
  end

  def path_for_broker_agencies
    broker_agencies_profile_path(id: current_user.person.broker_role.broker_agency_profile_id)
  end

  def path_for_employer_profile
    employers_employer_profile_path(id: current_user.person.active_employer_staff_roles.first.employer_profile_id)
  end

  def get_header_text(_controller_name)
    "<a class='portal'>#{Settings.site.header_message}</a>".html_safe
  end

  def site_main_web_address_business
    Settings.site.main_web_address_business
  end

  def site_faqs_url
    Settings.site.faqs_url
  end

  def dc_exchange?
    Settings.aca.state_abbreviation.upcase == 'DC'
  end

  def site_short_name
    Settings.site.short_name
  end

  # TODO: Add a similar notice attachment setting for DC
  def shop_non_discrimination_attachment
    Settings.notices.shop.attachments.non_discrimination_attachment
  end

  # TODO: Add a similar notice attachment setting for DC
  def shop_envelope_without_address
    Settings.notices.shop.attachments.envelope_without_address
  end

  def ivl_non_discrimination_attachment
    Settings.notices.individual.attachments.non_discrimination_attachment
  end

  def ivl_envelope_without_address
    Settings.notices.individual.attachments.envelope_without_address
  end

  def ivl_blank_page_attachment
    Settings.notices.individual.attachments.blank_page_attachment
  end

  def ivl_voter_application
    Settings.notices.individual.attachments.voter_application
  end

  def calculate_age_by_dob(dob)
    now = TimeKeeper.date_of_record
    now.year - dob.year - (now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1)
  end
end
