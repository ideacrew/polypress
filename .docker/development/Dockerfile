FROM ruby:2.7.3 AS polypress

LABEL author="IdeaCrew"

ENV HOME /polypress
RUN mkdir -p $HOME

# RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -


# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN apt-get update \
    && apt-get install -y wget gnupg vim tzdata nodejs npm \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# If running Docker >= 1.13.0 use docker run's --init arg to reap zombie processes, otherwise
# uncomment the following lines to have `dumb-init` as PID 1
# ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_x86_64 /usr/local/bin/dumb-init
# RUN chmod +x /usr/local/bin/dumb-init
# ENTRYPOINT ["dumb-init", "--"]

# Uncomment to skip the chromium download when installing puppeteer. If you do,
# you'll need to launch puppeteer with:
#     browser.launch({executablePath: 'google-chrome-stable'})
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Install puppeteer so it's available in the container.
RUN npm init -y &&  \
    npm i puppeteer
    # npm i puppeteer \
    # Add user so we don't need --no-sandbox.
    # same layer as npm install to keep re-chowned files from using up several hundred MBs more space
    # && groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
    # && mkdir -p /home/pptruser/Downloads \
    # && chown -R pptruser:pptruser /home/pptruser \
    # && chown -R pptruser:pptruser /node_modules \
    # && chown -R pptruser:pptruser /package.json \
    # && chown -R pptruser:pptruser /package-lock.json

# Run everything after as non-privileged user.
# USER pptruser
CMD ["google-chrome-stable"]
RUN export CHROME_DEVEL_SANDBOX=/usr/local/sbin/chrome-devel-sandbox

WORKDIR $HOME

# Configure bundler and PATH
ENV GEM_HOME="/usr/local/bundle"

ENV LANG=C.UTF-8 \
  BUNDLE_PATH=$GEM_HOME \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3
ENV BUNDLE_BIN=$BUNDLE_PATH/bin

RUN mkdir -p $BUNDLE_PATH && mkdir -p $BUNDLE_BIN
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

COPY . $HOME

RUN cd /node_modules/puppeteer/.local-chromium/linux-901912/chrome-linux && \
    chown root:root chrome_sandbox && \
    chmod 4755 chrome_sandbox && \
    # copy sandbox executable to a shared location
    cp -p chrome_sandbox /usr/local/sbin/chrome-devel-sandbox
    # export CHROME_DEVEL_SANDBOX env variable


RUN gem install --source "https://rubygems.org" bundler --version '2.2.24'

RUN cd $HOME && bundle install && bundle binstubs bundler
# RUN cd $HOME && yarn add @rails/webpacker@5.4.0 && yarn add --dev webpack-dev-server
# RUN cd $HOME && rails webpacker:install:erb
# RUN cd $HOME && yarn add bootstrap && yarn add @popperjs/core

RUN unset BUNDLE_PATH
RUN unset BUNDLE_BIN
