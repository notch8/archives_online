#!/usr/bin/env sh
COUNTER=0

if [ "$SOLR_ADMIN_USER" ]; then
  solr_user_settings="--user $SOLR_ADMIN_USER:$SOLR_ADMIN_PASSWORD"
fi

solr_config_name="${SOLR_CONFIGSET_NAME:-archives-online}"

solr_config_list_url="http://${SOLR_HOST}:${SOLR_PORT}/api/cluster/configs?omitHeader=true"
solr_config_upload_url="http://${SOLR_HOST}:${SOLR_PORT}/solr/admin/configs?action=UPLOAD&name=${solr_config_name}"

while [ $COUNTER -lt 30 ]; do
  echo "-- Looking for Solr (${SOLR_HOST}:${SOLR_PORT})..."
  if nc -z "${SOLR_HOST}" "${SOLR_PORT}"; then
    # Solr is up, check if config exists
    if curl --silent $solr_user_settings "$solr_config_list_url" | grep -q "$solr_config_name"; then
      echo "-- ConfigSet '${solr_config_name}' already exists; skipping upload."
      exit 0
    else
      echo "-- ConfigSet '${solr_config_name}' does not exist; uploading..."
      (cd "$CONFDIR" && zip -r - *) | curl -X POST $solr_user_settings --header "Content-Type:application/octet-stream" --data-binary @- "$solr_config_upload_url"
      exit 0
    fi
  fi
  COUNTER=$((COUNTER + 1))
  sleep 5s
done

echo "--- ERROR: Failed to upload Solr ConfigSet after 5 minutes."
exit 1
