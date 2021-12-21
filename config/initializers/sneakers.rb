require 'sneakers'
require 'sneakers/handlers/maxretry'
Sneakers.configure(
  {
        amqp: ENV['RABBITMQ_URL_EVENT_SOURCE'] || 'amqp://localhost:5672/',
        vhost: '/',
        heartbeat: 5,
        handler: Sneakers::Handlers::Maxretry
  }
)
