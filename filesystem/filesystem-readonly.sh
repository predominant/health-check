#!/bin/bash
#/
#/ Filesystem read only health check
#/ This check assumes that you want filesytems to be writable on
#/ the local server, and will WARN if any readonly filesystems are
#/ detected.
#/ This behaviour can be changed to force ERROR instead of WARNING
#/ by setting FS_READONLY_ERROR=1
#/
#/ Usage:
#/   filesystem-readonly.sh
#/   FS_READONLY_ERROR=1 filesystem-readonly.sh

. ../.common/common

# Configuration
# -------------------------------------
FS_READONLY_ERROR=${FS_READONLY_ERROR:-0}
# -------------------------------------

MOUNTS_RAW=$(cat /proc/mounts | grep "\sro[\s,]")
MOUNTS_STATUS=$?

REPORT_STATUS=${CHECK_STATE_UNKNOWN}
REPORT_TEXT="UNKNOWN | Unable to determine filesystem mount status"

# grep output will be '0' if readonly mounts are found
if [ ${MOUNTS_STATUS} -eq 0 ]; then
  if [ ${FS_READONLY_ERROR} -eq 0 ]; then
    REPORT_STATUS=${CHECK_STATE_WARNING}
    REPORT_TEXT="WARNING"
  else
    REPORT_STATUS=${CHECK_STATE_ERROR}
    REPORT_TEXT="ERROR"
  fi
  REPORT_TEXT="${REPORT_TEXT} | Some filesystems are marked as readonly | ${MOUNTS_RAW}"
else
  REPORT_STATUS=${CHECK_STATE_OK}
  REPORT_TEXT="OK | No readonly filesystem mounts found"
fi

exit_report ${REPORT_STATUS} ${REPORT_TEXT}
