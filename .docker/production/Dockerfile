########################
### app/rails config ###
########################

FROM public.ecr.aws/ideacrew/polypress:base AS app

LABEL author="IdeaCrew"

# Configure bundler and PATH, install bundler version
ENV LANG=C.UTF-8 \
    GEM_HOME=/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH \
    BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH $BUNDLE_BIN:$GEM_HOME/gems/bin:$PATH

ARG BUNDLER_VERSION_OVERRIDE
ENV BUNDLER_VERSION=$BUNDLER_VERSION_OVERRIDE
RUN gem update --system && gem install bundler:$BUNDLER_VERSION

# Configure app home directory
ENV HOME /polypress
RUN mkdir -p $HOME
WORKDIR $HOME
COPY . $HOME

RUN yarn install

# Setting env up
ENV RAILS_ENV='production'
ENV NODE_ENV='production'

ARG SECRET_KEY_BASE
ARG POLYPRESS_DB_HOST
ARG POLYPRESS_DB_PORT
ARG POLYPRESS_DB_NAME
ARG RABBITMQ_URL_EVENT_SOURCE
ARG RABBITMQ_HOST
ARG RABBITMQ_PORT
ARG RABBITMQ_VHOST
ARG MITC_HOST
ARG MITC_PORT
ARG MITC_URL
ENV POLYPRESS_DB_HOST=$POLYPRESS_DB_HOST
ENV POLYPRESS_DB_PORT=$POLYPRESS_DB_PORT
ENV POLYPRESS_DB_NAME=$POLYPRESS_DB_NAME
ENV RABBITMQ_URL_EVENT_SOURCE=$RABBITMQ_URL_EVENT_SOURCE
ENV RABBITMQ_HOST=$RABBITMQ_HOST
ENV RABBITMQ_PORT=$RABBITMQ_PORT
ENV RABBITMQ_VHOST=$RABBITMQ_VHOST
ENV MITC_HOST=$MITC_HOST
ENV MITC_PORT=$MITC_PORT
ENV MITC_URL=$MITC_URL
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

# Adding gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN bundle install --jobs 20 --retry 5 --without development test 
RUN bundle exec rake assets:precompile
#RUN rm -f /polypress/config/master.key && rm -f /polypress/config/credentials.yml.enc

#CMD ["./entrypoints/docker-entrypoint.sh"]


########################
### web/nginx config ###
######################## 

FROM nginx:1.17.6-alpine as web

RUN mkdir /polypress

# copy assets from the app build and nginx config
COPY --from=app /polypress/public /polypress/
COPY .docker/production/nginx.conf /etc/nginx/conf.d/polypress.conf
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf-bkp

