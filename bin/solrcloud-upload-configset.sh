#!/usr/bin/env sh

set -e

COUNTER=0
TIMEOUT=30

# Defaults
solr_config_name="${SOLR_CONFIGSET_NAME:-archives-online}"
solr_host="${SOLR_HOST:-solr}"
solr_port="${SOLR_PORT:-8983}"
confdir="${CONFDIR:-/opt/solr/server/solr/configsets/$solr_config_name}"

if [ "$SOLR_ADMIN_USER" ]; then
  solr_user_settings="--user $SOLR_ADMIN_USER:$SOLR_ADMIN_PASSWORD"
fi

solr_config_list_url="http://${solr_host}:${solr_port}/api/cluster/configs?omitHeader=true"
solr_config_upload_url="http://${solr_host}:${solr_port}/solr/admin/configs?action=UPLOAD&name=${solr_config_name}"

while [ $COUNTER -lt $TIMEOUT ]; do
  echo "-- Looking for Solr at ${solr_host}:${solr_port}..."
  if nc -z "${solr_host}" "${solr_port}"; then
    echo "-- Solr is up"

    if curl --silent $solr_user_settings "$solr_config_list_url" | grep -q "\"$solr_config_name\""; then
      echo "-- ConfigSet '$solr_config_name' already exists; skipping upload."
    else
      echo "-- ConfigSet '$solr_config_name' not found; uploading from $confdir..."
      (cd "$confdir" && zip -r - .) | curl -X POST $solr_user_settings \
        --header "Content-Type:application/octet-stream" \
        --data-binary @- "$solr_config_upload_url"
      echo "-- Upload complete"
    fi

    exit 0
  fi

  echo "-- Waiting for Solr..."
  COUNTER=$((COUNTER + 1))
  sleep 5s
done

echo "--- ERROR: Failed to connect to Solr at ${solr_host}:${solr_port} after $((TIMEOUT * 5)) seconds."
exit 1
