# frozen_string_literal: true

module Bodies
  class BodyModel
    include Mongoid::Document
    include Mongoid::Timestamps

    embedded_in :section, class_name: 'Sections::SectionModel'
    embedded_in :template, class_name: 'Templates::TemplateModel'

    field :markup, type: String
    field :content_type, type: String
    field :encoding_type, type: String

    validate :check_template_elements

    private

    def check_template_elements
      raw_text = markup.to_s.downcase
      errors.add(:base, 'has invalid elements') if Templates::TemplateModel::BLOCKED_ELEMENTS.any? {|str| raw_text.include?(str)}
    end
  end
end
