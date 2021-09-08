# frozen_string_literal: true

module Sections
  # Schema and validation rules for {Sections::Sections} domain object
  class SectionContract < Contract
    # @!method call(opts)
    # @param [Hash] opts the parameters to validate using this contract
    # @option opts [Hash] :sections required
    # @return [Dry::Monads::Result] :result
    params { required(:sections).value(:hash) }
  end
end
