# frozen_string_literal: true

# require 'yaml'
# Transform a Hash into YAML-formatted String
class SerializeYaml
  send(:include, Dry::Monads[:result, :do])

  # @param [Hash] Key/value pairs to transformed into YAML String
  # @return [Dry:Monad] passed params in YAML format
  def call(params)
    values = yield transform(params)
    Success(values)
  end

  private

  def transform(params)
    params_hash = params.to_h
    Success(params_hash.to_yaml)
  end
end
