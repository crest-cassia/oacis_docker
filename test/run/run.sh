#!/bin/bash

. ./test/base.sh

function run_oacis() {
  docker run --name oacis-mongo -d mongo:3.0.3
  docker run --name oacis -i -p ${PORT}:3000 --link oacis-mongo:mongo -d ${OACIS_IMAGE}
  sleep 20
  docker logs oacis
  curl localhost:${PORT}
}

run_oacis
rc=$?

exit $rc

