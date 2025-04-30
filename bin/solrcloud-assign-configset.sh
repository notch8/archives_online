#!/usr/bin/env sh
set -e

COUNTER=0;

if [ "$SOLR_ADMIN_USER" ]; then
  solr_user_settings="--user $SOLR_ADMIN_USER:$SOLR_ADMIN_PASSWORD"
fi

solr_config_name="${SOLR_CONFIGSET_NAME:-archives-online}"
solr_collection_name="${SOLR_COLLECTION_NAME:-archives-online}"

# Solr Cloud Collection API URLs
solr_collection_list_url="$SOLR_HOST:$SOLR_PORT/solr/admin/collections?action=LIST"
solr_collection_modify_url="$SOLR_HOST:$SOLR_PORT/solr/admin/collections?action=MODIFYCOLLECTION&collection=${solr_collection_name}&collection.configName=${solr_config_name}"
solr_collection_create_url="$SOLR_HOST:$SOLR_PORT/solr/admin/collections?action=CREATE&name=${solr_collection_name}&collection.configName=${solr_config_name}&numShards=1"

while [ $COUNTER -lt 30 ]; do
  echo "-- Looking for Solr (${SOLR_HOST}:${SOLR_PORT})..."
  if nc -z "${SOLR_HOST}" "${SOLR_PORT}"; then
    echo "-- Solr is up"

    if curl --silent $solr_user_settings "$solr_collection_list_url" | grep -q "$solr_collection_name"; then
      echo "-- Collection ${solr_collection_name} already exists"
      echo "-- Applying configSet ${solr_config_name} to existing collection..."
      echo $solr_collection_modify_url
      curl $solr_user_settings "$solr_collection_modify_url"
      exit
    else
      echo "-- Collection ${solr_collection_name} not found; creating it with configSet ${solr_config_name}..."
      echo "$solr_collection_create_url"
      curl -X POST $solr_user_settings "$solr_collection_create_url"
      exit
    fi
  fi
  COUNTER=$(( COUNTER+1 ));
  sleep 5s
done

echo "--- ERROR: failed to create/update Solr collection after 5 minutes";
exit 1