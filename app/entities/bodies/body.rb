# frozen_string_literal: true

module Bodies
  class Body < Dry::Struct
    attribute :markup, Types::Any.meta(omittable: false)
    attribute :encoding_type, Types::String.optional.meta(omittable: true)
    attribute :content_type, Types::String.optional.meta(omittable: true)
  end
end
