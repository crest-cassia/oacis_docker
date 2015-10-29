#!/bin/bash

set -eux

OACIS_IMAGE=${OACIS_IMAGE-"oacis/oacis"}
PORT=3100
OACIS_CONTAINER_NAME="ocais_docer_test"
OACIS_DATA_CONTAINER_NAME="ocais_docer_data_test"

function cleanup() {
  dockerps=`docker ps | grep "${OACIS_CONTAINER_NAME}[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    docker stop ${OACIS_CONTAINER_NAME}
  fi
  dockerps=`docker ps | grep "${OACIS_CONTAINER_NAME}[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    docker rm ${OACIS_CONTAINER_NAME}
  fi
  dockerps=`docker ps | grep "${OACIS_DATA_CONTAINER_NAME}[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    docker rm ${OACIS_DATA_CONTAINER_NAME}
  fi
}
trap cleanup EXIT

