#!/bin/bash

set -ux

function run_oacis() {
  docker run --name ${OACIS_CONTAINER_NAME} -p 127.0.0.1:${PORT}:3000 -d ${OACIS_IMAGE} || return 1
  for i in {0..20}
  do
    sleep 3
    curl localhost:${PORT} && return 0
  done
  docker logs ${OACIS_CONTAINER_NAME}
  return 1
}

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
    docker rm -v ${OACIS_CONTAINER_NAME}
  fi
}

trap cleanup EXIT ERR

