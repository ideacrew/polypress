# frozen_string_literal: true

module Services
  # Provides recipients and setting placeholders for individual market
  class IndividualNoticeService

    def recipients
      {
        'Application' => '::AcaEntities::MagiMedicaid::Application',
        'Family' => '::AcaEntities::Families::Family',
        'ConsumerRole' => 'AcaEntities::People::ConsumerRole'
      }
    end

    def setting_placeholders
      Config::SiteHelper.instance_methods(false).sort.each_with_object([]) do |method, placeholders|
        placeholders << {
          title: method.to_s.humanize,
          target: method
        }
      end
    end
  end
end
