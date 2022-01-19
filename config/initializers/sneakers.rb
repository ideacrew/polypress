# frozen_string_literal: true

require 'sneakers'
require 'sneakers/handlers/maxretry'

module ActiveJob
  module QueueAdapters
    class SneakersAdapter
      class JobWrapper # :nodoc:
        include Sneakers::Worker
        from_queue "#{Rails.application.config.active_job.queue_name_prefix}_default"

        def work(msg)
          job_data = ActiveSupport::JSON.decode(msg)
          Base.execute job_data
          ack!
        end
      end
    end
  end
end

Sneakers.configure(
  {
    amqp: ENV['RABBITMQ_URL_EVENT_SOURCE'] || 'amqp://localhost:5672/',
    vhost: '/',
    heartbeat: 10,
    workers: 1
  }
)
