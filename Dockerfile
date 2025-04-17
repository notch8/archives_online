FROM phusion/passenger-ruby32:latest AS base

ARG REPO_URL=https://github.com/notch8/archives_online.git

RUN echo 'Downloading Packages' && \
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get update -qq && \
    apt-get install -y \
      build-essential \
      gettext \
      libsasl2-dev \
      nodejs \
      pv \
      rsync \
      tzdata \
      mysql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    echo 'Packages Downloaded'

RUN rm /etc/nginx/sites-enabled/default

ENV APP_HOME /home/app/webapp
RUN mkdir $APP_HOME && chown -R app:app /home/app
WORKDIR $APP_HOME

ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
  BUNDLE_JOBS=4

COPY --chown=app:app Gemfile* $APP_HOME/
RUN /sbin/setuser app bash -l -c "bundle check || bundle install"

# Web stage
FROM base AS web

COPY ops/webapp.conf /etc/nginx/sites-enabled/webapp.conf
COPY ops/env.conf /etc/nginx/main.d/env.conf

COPY ops/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run
RUN rm -f /etc/service/nginx/down

RUN gem install bundler -v 2.4.22
COPY --chown=app:app Gemfile* $APP_HOME/
RUN /sbin/setuser app bash -l -c "bundle check || bundle install"

COPY --chown=app:app . $APP_HOME
RUN /sbin/setuser app bash -l -c " \
    cd /home/app/webapp && \
    yarn install && \
    NODE_ENV=production DB_ADAPTER=nulldb bundle exec rake assets:precompile"
RUN cp ./app/assets/stylesheets/print.scss ./public/assets/print.scss

CMD ["/sbin/my_init"]
