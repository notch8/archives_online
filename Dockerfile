FROM phusion/passenger-ruby32:latest AS base

ARG REPO_URL=https://github.com/notch8/archives_online.git

RUN echo 'Downloading Packages' && \
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get update -qq && \
    apt-get install -y \
      build-essential \
      gettext \
      libsasl2-dev \
      netcat-openbsd \
      nodejs \
      pv \
      rsync \
      tzdata \
      mysql-client \
      zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    echo 'Packages Downloaded'

RUN rm /etc/nginx/sites-enabled/default

# Set up app home
ENV APP_HOME /home/app/webapp
RUN mkdir $APP_HOME && chown -R app:app /home/app
WORKDIR $APP_HOME

# Bundle settings
ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
  BUNDLE_JOBS=4

# Install basic gems
COPY --chown=app:app Gemfile* $APP_HOME/
RUN /sbin/setuser app bash -l -c "bundle check || bundle install"

# Web stage
FROM base AS web

# Configure nginx
COPY ops/webapp.conf /etc/nginx/sites-enabled/webapp.conf
COPY ops/env.conf /etc/nginx/main.d/env.conf

COPY ops/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run
RUN rm -f /etc/service/nginx/down

# Install bundler version you need
RUN gem install bundler -v 2.4.22

# App files
COPY --chown=app:app Gemfile* $APP_HOME/
RUN /sbin/setuser app bash -l -c "bundle check || bundle install"

# Copy application code
COPY --chown=app:app . $APP_HOME

# ** ADD SOLR SCRIPTS INTO IMAGE **
COPY bin/solrcloud-upload-configset.sh /usr/local/bin/solrcloud-upload-configset.sh
COPY bin/solrcloud-assign-configset.sh /usr/local/bin/solrcloud-assign-configset.sh
RUN chmod +x /usr/local/bin/solrcloud-upload-configset.sh
RUN chmod +x /usr/local/bin/solrcloud-assign-configset.sh

# Precompile assets
RUN /sbin/setuser app bash -l -c " \
    cd /home/app/webapp && \
    yarn install && \
    NODE_ENV=production DB_ADAPTER=nulldb bundle exec rake assets:precompile"

# Entrypoint
CMD ["/sbin/my_init"]

FROM solr:8.3 AS solr
ENV SOLR_USER="solr" \
    SOLR_GROUP="solr"
USER root
COPY --chown=solr:solr solr/security.json /var/solr/data/security.json
USER $SOLR_USER