#!/bin/bash

. ./test/base.sh

OACIS_IMAGE="oacis/oacis"
PORT=3210
OACIS_CONTAINER_NAME="oacis_docker_test"

run_oacis
rc=$?
exit $rc

