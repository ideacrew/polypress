# setup docker image config
cp config/mongoid.yml config/mongoid.yml.tmp
cp config/environments/production.rb config/environments/production.rb.tmp
cp config/credentials.yml.enc config/credentials.yml.enc.tmp

cp .docker/config/mongoid.yml config/
cp .docker/config/production.rb config/environments/
cp .docker/config/credentials.yml.enc config/
cp .docker/config/master.key config/
cp .docker/config/secrets.yml config/

docker build --build-arg BUNDLER_VERSION_OVERRIDE='2.2.10' \
             --build-arg NODE_MAJOR='12' \
             --build-arg YARN_VERSION='1.22.4' \
             --build-arg POLYPRESS_DB_HOST='host.docker.internal' \
             --build-arg POLYPRESS_DB_PORT="27017" \
             --build-arg POLYPRESS_DB_NAME="polypress_production" \
             --build-arg RABBITMQ_HOST="amqp://rabbitmq" \
             --build-arg RABBITMQ_PORT="5672" \
             --build-arg RABBITMQ_VHOST="event_source" \
             --build-arg MITC_HOST="http://mitc" \
             --build-arg MITC_PORT="3001" \
             --build-arg MITC_URL="http://mitc:3001" \
             -f .docker/production/Dockerfile --target app -t $2:$1 --network="host" .
docker push $2:$1

mv config/mongoid.yml.tmp config/mongoid.yml
mv config/environments/production.rb.tmp config/environments/production.rb
mv config/credentials.yml.enc.tmp config/credentials.yml.enc
rm config/master.key
rm config/secrets.yml
