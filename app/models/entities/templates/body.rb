# frozen_string_literal: true

module Entities
  module Templates
    # A Template contains structured and unstructured text and associated content to be output into a document
    class Body < Dry::Struct

      attribute :header,    Polypress::Types::String.meta(omittable: false)
      attribute :footer,    Polypress::Types::String.meta(omittable: false)
      attribute :main,      Polypress::Types::String.meta(omittable: true)
    end
  end
end