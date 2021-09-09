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
  field :category, type: String

  embeds_one :body, as: :section_body
end
