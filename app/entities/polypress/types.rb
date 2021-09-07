# frozen_string_literal: true

require 'dry-types'

module Polypress
  # Polypress types
  module Types
    send(:include, Dry.Types)
    send(:include, Dry::Logic)

    CategoryKind = Types::Coercible::String.enum('aca_individual', 'aca_shop')

    MimeType =
      Types.Constructor(Mime::Type) do |value|
        value = 'text/html' if value.empty?
        Mime::Type.lookup(value)
      end

    SectionKind = Types::Coercible::String.enum('body', 'component')
  end
end
