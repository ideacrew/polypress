FROM ruby:2.7.3 AS polypress

LABEL author="IdeaCrew"

ENV HOME /polypress
RUN mkdir -p $HOME
WORKDIR $HOME

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

RUN apt-get update \
  && apt-get -yq dist-upgrade \
  && apt-get install -y tzdata build-essential nodejs vim wget gnupg \
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
    --no-install-recommends \
  && npm install --global yarn \
  && rm -rf /var/lib/apt/lists/*
  # && apt-get autoremove -y \

# Configure bundler and PATH
ENV GEM_HOME="/usr/local/bundle"

ENV LANG=C.UTF-8 \
  BUNDLE_PATH=$GEM_HOME \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3
ENV BUNDLE_BIN=$BUNDLE_PATH/bin

# Install puppeteer so it's available in the container.
RUN npm init -y &&  \
    npm i puppeteer \
    # Add user so we don't need --no-sandbox.
    # same layer as npm install to keep re-chowned files from using up several hundred MBs more space
    && groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser
    # && chown -R pptruser:pptruser /package-lock.json
    # && chown -R pptruser:pptruser /package.json \
    # && chown -R pptruser:pptruser /node_modules \

# Run everything after as non-privileged user.
USER pptruser
CMD ["google-chrome-stable"]

RUN mkdir -p $BUNDLE_PATH && mkdir -p $BUNDLE_BIN

ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

COPY . $HOME

RUN gem install --source "https://rubygems.org" bundler --version '2.2.24'

RUN cd $HOME && bundle install && bundle binstubs bundler
# RUN cd $HOME && yarn add @rails/webpacker@5.4.0 && yarn add --dev webpack-dev-server
# RUN cd $HOME && rails webpacker:install:erb
# RUN cd $HOME && yarn add bootstrap && yarn add @popperjs/core

RUN unset BUNDLE_PATH
RUN unset BUNDLE_BIN
