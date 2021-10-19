# frozen_string_literal: true

require Rails.root.join('app', 'entities', 'polypress', 'types.rb')

PolypressRegistry = ResourceRegistry::Registry.new

PolypressRegistry.configure do |config|
  config.name = :enroll
  config.created_at = DateTime.now
  config.load_path =
    Rails.root.join('system', 'config', 'templates', 'features').to_s
end
