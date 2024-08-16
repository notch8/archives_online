#!/bin/bash

set -e

if [[ "$VERBOSE" = "yes" ]]; then
    set -x
fi

cp /opt/solr/server/solr/solr.xml $SOLR_HOME/

. /opt/docker-solr/scripts/run-initdb

SOLR_CONFIG_DIR=/solr_conf

blacklight_created=$SOLR_HOME/blacklight_created

if [ -f $blacklight_created ]; then
    echo "skipping solr core creation"
else
    start-local-solr

    if [ ! -f $blacklight_created ]; then
        echo "Creating blacklight core(s)"
        /opt/solr/bin/solr create -c "blacklight-core" -d "$SOLR_CONFIG_DIR/blacklight_config"
        touch $blacklight_created
    fi

    stop-local-solr
fi

exec solr -f -m 4g