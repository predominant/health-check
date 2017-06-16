#!/bin/bash
#/
#/ General passthrough for all health checks
#/
#/ Usage:
#/   ./check.sh
#/     Returns this usage information
#/   ./check.sh filesystem-readonly
#/     Includes the filesystem/filesystem-readonly.sh check and executes it
#/

. ./.common/common

if [ $# -eq 0 ]; then
  usage
  exit 1
elif [ $# -eq 1 ]; then
  CHECK_FULLNAME=$1
  CHECK_DIR=$(echo -e "${CHECK_FULLNAME}" | awk -F'-' '{print $1}')
  CHECK_FILE="${CHECK_DIR}-$(echo -e "${CHECK_FULLNAME}" | awk -F'-' '{print $2 ".sh"}')"
  CHECK_PATH="./${CHECK_DIR}/${CHECK_FILE}"

  if [ ! -f "${CHECK_PATH}" ]; then
    echo "Error: The specified health check does not exist: ${CHECK_PATH}"
    exit 1
  fi

  pushd ${CHECK_DIR}
  . ${CHECK_FILE}
  popd
fi
