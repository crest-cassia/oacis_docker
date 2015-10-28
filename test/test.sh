#!/bin/bash

. ./test/base.sh

function docker_run_oacis() {
  docker run --name oacis-mongo -d mongo:3.0.3
  docker run --name oacis --link oacis-mongo:mongo -d oacis/oacis
  sleep 15
  curl localhost:3000
}

docker_run_oacis

