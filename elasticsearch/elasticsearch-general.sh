#!/bin/bash
#/
#/ General Health Check for ElasticSearch
#/ See environment variables at the top of this file for
#/ an indication of what can be set / overridden.
#/
#/ Usage:
#/   elasticsearch-general.sh
#/   ES_HOST=example.com elasticsearch-general.sh
#/

. ../.common/common
. ../.common/curl

# Configuration
# -------------------------------------
ES_HOST=${ES_HOST:-http://localhost}
ES_PORT=${ES_PORT:-9200}
ES_PATH=${ES_PATH:-/_cat/health}
# -------------------------------------

ES_URL="${ES_HOST}:${ES_PORT}${ES_PATH}"
ES_DATA=$(curl -fsSL "${ES_URL}" 2>&1)
CURL_STATUS=$?
if [ ${CURL_STATUS} -eq ${CURLE_OK} ]; then
  ES_DATA_PRETTY=$(echo -e "${ES_DATA}" | awk '{print "Status:" $4,"ActiveShards:" $14,"NodeCount:" $5,"DataNodes:" $6,"Shards:" $7,"PrimaryShards:" $8,"Relocating:" $9,"Initializing:" $10,"Unassigned:" $11}')
  ES_STATUS=$(echo -e "${ES_DATA}" | awk '{print $4}')

  REPORT_STATUS=${CHECK_STATE_UNKNOWN}
  REPORT_TEXT="Status is unknown | ${ES_DATA_PRETTY}"

  if [ "${ES_STATUS}" == "green" ]; then
    REPORT_STATUS=${CHECK_STATE_OK}
    REPORT_TEXT="OK | ${ES_DATA_PRETTY}"
  elif [ "${ES_STATUS}" == "orange" ]; then
    REPORT_STATUS=${CHECK_STATE_WARNING}
    REPORT_TEXT="WARNING | ${ES_DATA_PRETTY}"
  elif [ "${ES_STATUS}" == "red" ]; then
    REPORT_STATUS=${CHECK_STATE_ERROR}
    REPORT_TEXT="ERROR | ${ES_DATA_PRETTY}"
  fi
else
  REPORT_STATUS=${CHECK_STATE_ERROR}
  REPORT_TEXT="ERROR | Failed communicating with server at ${ES_URL} | ${ES_DATA}"
fi

exit_report ${REPORT_STATUS} ${REPORT_TEXT}
