# frozen_string_literal: true

module Sections
  # Mongoid peristance model for {Sections::Section} entity
  class SectionModel
    include Mongoid::Document
    include Mongoid::Timestamps

    field :key, type: String
    field :title, type: String
    field :description, type: String
    field :marketplace, type: String, default: 'aca_individual'
    field :locale, type: String
    field :author, type: String
    field :updated_by, type: String

    embeds_one :body, class_name: 'Bodies::BodyModel'
    accepts_nested_attributes_for :body

    index({ key: 1 }, { unique: true, name: 'key_index' })

    scope :all, -> { exists(_id: true) }
    scope :by_key, ->(value) { where(key: value[:value]) }
    scope :by_id, ->(value) { value[:_id] }

    def to_entity
      serializable_hash.merge('_id' => id.to_s).deep_symbolize_keys
    end
  end
end
