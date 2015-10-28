#!/bin/bash

. ./test/base.sh

function run_oacis() {
  docker run --name oacis -p ${PORT}:3000 -d ${OACIS_IMAGE}
  sleep 20
  docker logs oacis
  curl localhost:${PORT}
}

run_oacis
rc=$?

exit $rc

