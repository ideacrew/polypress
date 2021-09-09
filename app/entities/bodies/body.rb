# frozen_string_literal: true

module Bodies
  class Body < Dry::Struct
    attribute :markup, Types::Any
    attribute :encoding_type, Types::String
    attribute :content_type, Types::String
  end
end
