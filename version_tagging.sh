#!/bin/bash

# before running this script, run `docker login`
set -eux
OACIS_VERSION="v3.9.0"

docker login
SCRIPT_DIR=$(cd $(dirname $0);pwd)
cd $SCRIPT_DIR/oacis
docker build . -t oacis/oacis:${OACIS_VERSION} --build-arg OACIS_VERSION=${OACIS_VERSION}
docker push oacis/oacis:${OACIS_VERSION}
docker tag oacis/oacis:${OACIS_VERSION} oacis/oacis:latest
docker push oacis/oacis:latest

cd $SCRIPT_DIR/oacis_jupyter
docker build . -t oacis/oacis_jupyter:${OACIS_VERSION} --build-arg OACIS_VERSION=${OACIS_VERSION}
docker push oacis/oacis_jupyter:${OACIS_VERSION}
docker tag oacis/oacis_jupyter:${OACIS_VERSION} oacis/oacis_jupyter:latest
docker push oacis/oacis_jupyter:latest
