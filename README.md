# Polypress Service

The Polypress service is a digital printing press that produces notices and reports for
the State-based Exchange

## Docker Setup

Build Docker environment

```bash
docker-compose build
```

Find the RabbitMQ container

```bash
docker ps

CONTAINER ID   IMAGE                     COMMAND                  CREATED         STATUS         PORTS
c485144f966   rabbitmq:3.8-management   "docker-entrypoint.s…"   3 minutes ago   Up 3 minutes
```

Connect to the RabbitMQ Container command line, add the `event_source` vhost and grant permissions
to the `guest` account

```bash
docker exec -it c485144f966 bash

root@cc485144f966:/# rabbitmqctl add_vhost event_source
root@cc485144f966:/# rabbitmqctl set_permissions -p event_source guest ".*" ".*" ".*"
```

- Ruby version: 2.7.2
- Rails version: 6.1.3.2
- Tests: RSpec
- Database: MongoDB
