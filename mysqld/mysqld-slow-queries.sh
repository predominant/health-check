#!/bin/bash
#/
#/ MySQLd Slow Queries Check
#/ Checks the specified MySQLd server for slow queries
#/ by inspecting the current processlist. Note that this
#/ does not use the SLOW GLOBAL STATUS method, as this
#/ can lead to false positives in a long running system.
#/ For this script to catch slow queries, it needs to be
#/ called at least every (long_query_time / 0.75) seconds.
#/
#/ Usage:
#/   mysqld-slow-queries.sh
#/   mysqld-slow-queries.sh -H localhost -w 4 -c 8

. ../.common/common

# Configuration
# -------------------------------------
MYSQLD_HOST=${MYSQLD_HOST:-localhost}
MYSQLD_PORT=${MYSQLD_PORT:-3306}
MYSQLD_USER=${MYSQLD_USER}
MYSQLD_PASS=${MYSQLD_PASS}
MYSQLD_WARNING=${MYSQLD_WARNING:-4}
MYSQLD_CRITICAL=${MYSQLD_CRITICAL:-8}
# -------------------------------------

echo "$@"
echo $0
echo $1
ARGS=$(getopt --name "$0" --long warning:,critical:,host:,port:,user:,pass:,help --options w:c:H:P:u:p:h -- "$@") || {
  usage
  exit 2
}
echo $ARGS
eval set -- $ARGS
echo $1
while [ $# -gt 0 ]; do
  case "$1" in
    -H|--host)
      MYSQLD_HOST=$2
      shift
      ;;
    -P|--port)
      MYSQLD_PORT=$2
      shift
      ;;
    -u|--user)
      MYSQLD_USER=$2
      shift
      ;;
    -p|--pass)
      MYSQLD_PASS=$2
      shift
      ;;
    -w|--warning)
      MYSQLD_WARNING=$2
      shift
      ;;
    -c|--critical)
      MYSQLD_CRITICAL=$2
      shift
      ;;
    -h|--help)
      usage
      exit 2
      ;;
    --)
      shift
      break
      ;;
  esac
  shift
done

REPORT_STATUS=${CHECK_STATE_UNKNOWN}
REPORT_TEXT="Status is unknown"

SQL_COMMAND="SELECT * FROM information_schema.PROCESSLIST WHERE Time > (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_VARIABLES WHERE VARIABLE_NAME = 'LONG_QUERY_TIME') AND NOT DB IS NULL AND COMMAND <> 'Sleep';"
RAW_RESULTS=$(mysql -u ${MYSQLD_USER} -p${MYSQLD_PASS} -H ${MYSQLD_HOST} -P ${MYSQLD_PORT} --silent --raw --execute "${SQL_COMMAND}")
RESULT_COUNT=$(echo -e "${RAW_RESULTS}" | wc -l)
if [ "$RESULT_COUNT" -ne "0" ]; then
  RESULT_COUNT=$(( $RESULT_COUNT - 1 ))
  if [ $RESULT_COUNT -gte $MYSQLD_CRITICAL]; then
    REPORT_STATUS=${CHECK_STATE_ERROR}
    REPORT_TEXT="ERROR"
  elif [ $RESULT_COUNT -gte $MYSQLD_WARNING ]; then
    REPORT_STATUS=${CHECK_STATE_WARNING}
    REPORT_TEXT="WARNING"
  else
    REPORT_STATUS=${CHECK_STATE_OK}
    REPORT_TEXT="OK"
  fi
  REPORT_TEXT="${REPORT_TEXT} | Slow query count is ${RESULT_COUNT}"
else
  REPORT_STATUS=${CHECK_STATE_OK}
  REPORT_TEXT="OK | No slow queries"
fi

exit_report ${REPORT_STATUS} ${REPORT_TEXT}
