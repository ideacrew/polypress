# frozen_string_literal: true

class Block
  attribute :key, Types::String
  attribute :type, Types::String
  attribute :attributes, Types::String

  attribute :title, Types::String
  attribute :description, Types::String
  attribute :content, Types::String
  attribute :settings, Types::String
end
