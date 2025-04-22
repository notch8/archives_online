#!/bin/bash
set -e

# Nginx log forwarder handling
if [[ ! -e /var/log/nginx/error.log ]]; then
    # The Nginx log forwarder might be sleeping and waiting
    # until the error log becomes available. We restart it in
    # 1 second so that it picks up the new log file quickly.
    (sleep 1 && sv restart /etc/service/nginx-log-forwarder)
fi

# Set default Passenger app environment
if [ -z $PASSENGER_APP_ENV ]; then
    export PASSENGER_APP_ENV=development
fi

# Clean up Ruby cache
rm -rf /home/app/webapp/.ruby*

# Export container environment variables
declare -p | grep -Ev 'BASHOPTS|PWD|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' > /container.env

# Database setup based on environment
if [[ $PASSENGER_APP_ENV == "development" ]] || [[ $PASSENGER_APP_ENV == "test" ]]; then

    echo "Running database initialization script..."
    cd /home/app/webapp
    ./generate-init.sh

    /sbin/setuser app /bin/bash -l -c 'cd /home/app/webapp && bundle exec rails db:create db:migrate db:test:prepare'
    /sbin/setuser app /bin/bash -l -c 'cd /home/app/webapp && yarn install'
fi

if [[ $PASSENGER_APP_ENV == "production" ]] || [[ $PASSENGER_APP_ENV == "staging" ]]; then
    /sbin/setuser app /bin/bash -l -c 'cd /home/app/webapp && bundle exec rake db:migrate'
    /sbin/setuser app /bin/bash -l -c 'cd /home/app/webapp && yarn install'

    if [ -d /home/app/webapp/public/assets-new ]; then
        /sbin/setuser app /bin/bash -l -c 'cd /home/app/webapp && rsync -a public/assets-new/ public/assets/'
    fi
    if [ -d /home/app/webapp/public/packs-new ]; then
        /sbin/setuser app /bin/bash -l -c 'cd /home/app/webapp && rsync -a public/packs-new/ public/packs/'
    fi
fi

exec /usr/sbin/nginx
