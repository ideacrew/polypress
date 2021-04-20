# frozen_string_literal: true

module Entities
  module Bodies
    # A Template contains structured and unstructured text and associated content to be output into a document
    class Body < Dry::Struct

      attribute :header,    Types::String.meta(omittable: false)
      attribute :footer,    Types::String.meta(omittable: false)
      attribute :main,   Types::String.meta(omittable: true)
    end
  end
end