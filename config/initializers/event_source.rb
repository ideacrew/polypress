# frozen_string_literal: true

EventSource.configure do |config|
  config.application = :polypress
  config.adapter = :resque_bus
  config.root    = Rails.root.join('app', 'event_source')
  config.logger  = Rails.root.join('log', 'event_source.log')
end