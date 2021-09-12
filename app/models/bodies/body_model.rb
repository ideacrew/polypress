class Bodies::BodyModel
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :section, class_name: 'Sections::SectionModel'
  embedded_in :template, class_name: 'Templates::TemplateModel'

  field :markup, type: String
  field :content_type, type: String
  field :encoding_type, type: String
end
