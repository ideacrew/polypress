# frozen_string_literal: true

EventSource.configure do |config|
  config.protocols = %w[amqp http]
  config.app_name = :polypress
  config.pub_sub_root =
    Pathname.pwd.join('spec', 'rails_app', 'app', 'event_source')

  config.server_key = ENV['RAILS_ENV'] || Rails.env.to_sym

  config.servers do |server|
    server.amqp do |rabbitmq|
      rabbitmq.host = ENV['RABBITMQ_HOST'] || 'amqp://localhost'
      warn rabbitmq.host
      rabbitmq.vhost = ENV['RABBITMQ_VHOST'] || '/'
      warn rabbitmq.vhost
      rabbitmq.port = ENV['RABBITMQ_PORT'] || '5672'
      warn rabbitmq.port
      rabbitmq.url = ENV['RABBITMQ_URL'] || 'amqp://localhost:5672/'
      warn rabbitmq.url
      rabbitmq.user_name = ENV['RABBITMQ_USERNAME'] || 'guest'
      warn rabbitmq.user_name
      rabbitmq.password = ENV['RABBITMQ_PASSWORD'] || 'guest'
      warn rabbitmq.password
      # rabbitmq.default_content_type =
      #   ENV['RABBITMQ_CONTENT_TYPE'] || 'application/json'
    end
  end

  async_api_resources =
      ::AcaEntities.async_api_config_find_by_service_name(
        { protocol: :amqp, service_name: nil }
      ).success

  config.async_api_schemas =
    async_api_resources.collect do |resource|
      EventSource.build_async_api_resource(resource)
    end
end

EventSource.initialize!
