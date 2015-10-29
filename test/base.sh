#!/bin/bash

set -eux

OACIS_IMAGE=${OACIS_IMAGE-"oacis/oacis"}
PORT=3100
OACIS_CONTAINER_NAME="oacis_docer_test"
OACIS_DATA_CONTAINER_NAME="oacis_docer_data_test"

function cleanup() {
  set +e
  dockerps=`docker ps | grep "${OACIS_CONTAINER_NAME}[\ ]*$"`
  set -e
  if [ -n "$dockerps" ]
  then
    docker stop ${OACIS_CONTAINER_NAME}
  fi
  set +e
  dockerps=`docker ps -a | grep "${OACIS_CONTAINER_NAME}[\ ]*$"`
  set -e
  if [ -n "$dockerps" ]
  then
    docker rm ${OACIS_CONTAINER_NAME}
  fi
  set +e
  dockerps=`docker ps -a | grep "${OACIS_DATA_CONTAINER_NAME}[\ ]*$"`
  set -e
  if [ -n "$dockerps" ]
  then
    docker rm ${OACIS_DATA_CONTAINER_NAME}
  fi
}
trap cleanup EXIT

