#!/bin/bash

set -eux

function run_oacis() {
  docker run --name ${OACIS_CONTAINER_NAME} -p 127.0.0.1:${PORT}:3000 -d ${OACIS_IMAGE}
  sleep 20
  docker logs ${OACIS_CONTAINER_NAME}
  curl localhost:${PORT}
}

function cleanup() {
  # grep returns non zero code when the pattern is missing.
  set +e

  dockerps=`docker ps | grep "${OACIS_CONTAINER_NAME}[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    docker stop -t 30 ${OACIS_CONTAINER_NAME}
  fi
  dockerps=`docker ps -a | grep "${OACIS_CONTAINER_NAME}[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    docker rm -v ${OACIS_CONTAINER_NAME}
  fi
}

