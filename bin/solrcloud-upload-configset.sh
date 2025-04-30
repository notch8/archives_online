#!/usr/bin/env sh
set -e

COUNTER=0
TIMEOUT=30
CONFDIR="${1:-/home/app/webapp/solr/conf}"

if [ -z "$CONFDIR" ] || [ ! -d "$CONFDIR" ]; then
  echo "--- ERROR: ConfigSet directory '$CONFDIR' not found"
  exit 1
fi

if [ "$SOLR_ADMIN_USER" ]; then
  solr_user_settings="--user $SOLR_ADMIN_USER:$SOLR_ADMIN_PASSWORD"
fi

solr_config_name="${SOLR_CONFIGSET_NAME:-archives-online}"
solr_config_list_url="http://${SOLR_HOST}:${SOLR_PORT}/api/cluster/configs?omitHeader=true"
solr_config_upload_url="http://${SOLR_HOST}:${SOLR_PORT}/solr/admin/configs?action=UPLOAD&name=${solr_config_name}&overwrite=true"

while [ $COUNTER -lt $TIMEOUT ]; do
  echo "-- Looking for Solr at ${SOLR_HOST}:${SOLR_PORT}..."
  if nc -z "${SOLR_HOST}" "${SOLR_PORT}"; then
    echo "-- Solr is up"

    # Check if Solr requires auth
    if curl --silent --user 'fake:fake' "$solr_config_list_url" | grep -q '401'; then
      echo "-- Auth is required to access Solr configsets"

      if curl --silent $solr_user_settings "$solr_config_list_url" | grep -q "\"$solr_config_name\""; then
        echo "-- ConfigSet '${solr_config_name}' already exists; skipping upload"
      else
        echo "-- Uploading ConfigSet '${solr_config_name}' from '${CONFDIR}'..."
        (cd "$CONFDIR" && zip -r -0 - .) | curl -X POST $solr_user_settings \
          --header "Content-Type:application/octet-stream" \
          --data-binary @- "$solr_config_upload_url"
        echo "-- ConfigSet '${solr_config_name}' upload complete"
      fi
      exit 0
    else
      echo "-- Solr is accepting unauthenticated requests; deferring upload until auth is ready"
    fi
  fi

  COUNTER=$((COUNTER + 1))
  sleep 5s
done

echo "--- ERROR: failed to upload Solr ConfigSet '${solr_config_name}' after $((TIMEOUT * 5)) seconds"
exit 1
