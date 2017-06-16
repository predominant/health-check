#!/bin/bash
#/
#/ NTPd offset health check
#/ See environment variables at the top of this file for
#/ an indication of what can be set / overridden.
#/
#/ Usage:
#/   ntpd-offset.sh
#/   NTP_OFFSET_WARN=30 ntpd-offset.sh
#/

. ../.common/common

# Configuration
# -------------------------------------
NTPD_OFFSET_WARN=${NTP_OFFSET_WARN:-50}
NTPD_OFFSET_ERROR=${NTP_OFFSET_ERROR:-100}
NTPDC_PATH=${NTPDC_PATH:-ntpdc}
# -------------------------------------

OFFSETS_RAW=$(${NTPDC_PATH} -nc peers 2>&1)
NTPDC_STATUS=$?
OFFSETS=$(echo -e "${OFFSETS_RAW}" | tail -n +3 | awk '{print $7}' | tr -d '-' 2>&1)

REPORT_STRING="UNKNOWN | NTPd offset is unknown: ${OFFSETS_RAW}"
REPORT_STATUS=${CHECK_STATE_UNKNOWN}

if [ ${NTPDC_STATUS} -ne 0 ]; then
  REPORT_STRING="ERROR | Error running ntpdc check: ${OFFSETS_RAW}"
  REPORT_STATUS=${CHECK_STATE_ERROR}
else
  for OFFSET in ${OFFSETS}; do
    if [ ${OFFSET:-0} -ge ${NTPD_OFFSET_WARN} ]; then
      REPORT_STRING="WARN | NTPd offset is high (${OFFSET})"
      REPORT_STATUS=${CHECK_STATE_WARNING}
    elif [ ${OFFSET:-0} -ge ${NTPD_OFFSET_ERROR} ]; then
      REPORT_STRING="ERROR | NTPd offset is excessive (${OFFSET})"
      REPORT_STATUS=${CHECK_STATE_ERROR}
    else
      REPORT_STRING="OK | NTPd offset is OK (${OFFSET})"
      REPORT_STATUS=${CHECK_STATE_OK}
    fi
  done
fi

exit_report ${REPORT_STATUS} ${REPORT_STRING}
