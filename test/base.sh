#!/bin/bash

set -eux

OACIS_IMAGE=${OACIS_IMAGE-"oacis/oacis"}
PORT=3210
OACIS_CONTAINER_NAME="oacis_docker_test"
OACIS_DATA_CONTAINER_NAME="oacis_docker_data_test"

function cleanup() {
  # grep returns non zero code when the pattern is missing.
  set +e

  dockerps=`docker ps | grep "${OACIS_CONTAINER_NAME}[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    docker stop ${OACIS_CONTAINER_NAME}
  fi
  dockerps=`docker ps -a | grep "${OACIS_CONTAINER_NAME}[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    docker rm ${OACIS_CONTAINER_NAME}
  fi
  dockerps=`docker ps -a | grep "${OACIS_DATA_CONTAINER_NAME}[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    docker rm ${OACIS_DATA_CONTAINER_NAME}
  fi
}
trap cleanup EXIT ERR

