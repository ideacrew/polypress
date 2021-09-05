# frozen_string_literal: true

require 'dry-types'

module Polypress
  # Polypress types
  module Types
    send(:include, Dry.Types)
    send(:include, Dry::Logic)

    CategoryKind = Types::Coercible::String.enum('aca_individual', 'aca_shop')
  end
end
