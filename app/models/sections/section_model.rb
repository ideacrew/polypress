# frozen_string_literal: true

class Sections::SectionModel
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key, type: String
  field :title, type: String
  field :kind, type: String
  field :description, type: String

  field :locale, type: String
  field :print_code, type: String
  field :author, type: String
  field :updated_by, type: String

  embeds_one :body, class_name: 'Bodies::BodyModel'
  accepts_nested_attributes_for :body

  index({ key: 1 }, { unique: true, name: 'key_index' })
end
