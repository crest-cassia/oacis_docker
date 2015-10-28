#!/bin/bash

set -e
set +x

OACIS_IMAGE=${OACIS_IMAGE-"oacis/oacis"}
PORT=3100

function cleanup() {
  docker stop oacis-mongo
  docker stop oacis
  docker rm oacis-mongo
  docker rm oacis
  exit 0
  dockerps=$(docker ps -q)
  if [ -n "$dockerps" ]
  then
    for pshash in `docker ps -q`
    do
      docker stop $pshash
    done
  fi
  dockerps=$(docker ps -a -q)
  if [ -n "$dockerps" ]
  then
    for pshash in `docker ps -a -q`
    do
      docker rm $pshash
    done
  fi
}
trap cleanup 0

