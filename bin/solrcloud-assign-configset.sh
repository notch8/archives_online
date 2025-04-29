#!/usr/bin/env sh

set -e

COUNTER=0
TIMEOUT=30

# Default variables
SOLR_HOST="${SOLR_HOST:-solr}"
SOLR_PORT="${SOLR_PORT:-8983}"
SOLR_CONFIGSET_NAME="${SOLR_CONFIGSET_NAME:-archives-online}"
CONFDIR="${CONFDIR:-/opt/solr/server/solr/configsets/$SOLR_CONFIGSET_NAME}"

if [ "$SOLR_ADMIN_USER" ]; then
  solr_user_settings="--user $SOLR_ADMIN_USER:$SOLR_ADMIN_PASSWORD"
fi

solr_config_list_url="http://${SOLR_HOST}:${SOLR_PORT}/api/cluster/configs?omitHeader=true"
solr_config_upload_url="http://${SOLR_HOST}:${SOLR_PORT}/solr/admin/configs?action=UPLOAD&name=${SOLR_CONFIGSET_NAME}"

# Wait for Solr to be up and ready
while [ $COUNTER -lt $TIMEOUT ]; do
  echo "-- Looking for Solr at ${SOLR_HOST}:${SOLR_PORT}..."
  if nc -z "${SOLR_HOST}" "${SOLR_PORT}"; then
    echo "-- Solr is up."

    if curl --silent $solr_user_settings "$solr_config_list_url" | grep -q "\"$SOLR_CONFIGSET_NAME\""; then
      echo "-- ConfigSet '${SOLR_CONFIGSET_NAME}' already exists; skipping upload."
      exit 0
    else
      echo "-- ConfigSet '${SOLR_CONFIGSET_NAME}' not found; uploading from '${CONFDIR}'..."
      (cd "$CONFDIR" && zip -r - .) | curl -X POST $solr_user_settings \
        --header "Content-Type:application/octet-stream" \
        --data-binary @- "$solr_config_upload_url"
      echo "-- ConfigSet upload complete."
      exit 0
    fi
  fi

  COUNTER=$((COUNTER + 1))
  sleep 5s
done

echo "--- ERROR: Failed to connect to Solr at ${SOLR_HOST}:${SOLR_PORT} after $((TIMEOUT * 5)) seconds."
exit 1
