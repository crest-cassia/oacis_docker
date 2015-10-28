#!/bin/bash

set -eux

OACIS_IMAGE=${OACIS_IMAGE-"oacis/oacis"}
PORT=3100

function cleanup() {
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

