# frozen_string_literal: true

EventSource.configure do |config|
  config.protocols = %w[amqp http]
  config.pub_sub_root =
    Pathname.pwd.join('spec', 'rails_app', 'app', 'event_source')

  config.server_key = ENV['RAILS_ENV'] # production, development# Rails.env.to_sym

  config.servers do |server|
    server.amqp do |rabbitmq|
      rabbitmq.host = ENV['RABBITMQ_HOST'] || 'amqp://localhost'
      STDERR.puts rabbitmq.host
      rabbitmq.vhost = ENV['RABBITMQ_VHOST'] || 'event_source'
      STDERR.puts rabbitmq.vhost
      rabbitmq.port = ENV['RABBITMQ_PORT'] || '5672'
      STDERR.puts rabbitmq.port
      rabbitmq.url = ENV['RABBITMQ_URL'] || ''
      STDERR.puts rabbitmq.url
      rabbitmq.user_name = ENV['RABBITMQ_USERNAME'] || 'guest'
      STDERR.puts rabbitmq.user_name
      rabbitmq.password = ENV['RABBITMQ_PASSWORD'] || 'guest'
      STDERR.puts rabbitmq.password
      # rabbitmq.url = "" # ENV['RABBITMQ_URL']
    end
  end

  app_schemas =
    Gem
      .loaded_specs
      .values
      .inject([]) do |ps, s|
        ps.concat(s.matches_for_glob('aca_entities/async_api/polypress.yml'))
      end

  config.async_api_schemas =
    app_schemas.map do |schema|
      EventSource::AsyncApi::Operations::AsyncApiConf::LoadPath
        .new
        .call(path: schema)
        .success
        .to_h
    end

  # config.asyncapi_resources = [AcaEntities::AsyncApi::MedicaidGataway]
  # config.asyncapi_resources = AcaEntities.find_resources_for(:enroll, %w[amqp resque_bus]) # will give you resouces in array of hashes form
  # AcaEntities::Operations::AsyncApi::FindResource.new.call(self)
end

EventSource.initialize!
