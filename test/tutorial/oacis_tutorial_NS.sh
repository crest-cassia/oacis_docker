#!/bin/bash

. ./test/base.sh

function restore_tutorial_NS() {
  docker run --name ${OACIS_CONTAINER_NAME} -p ${PORT}:3000 -d -e OACIS_TUTORIAL=oacis_tutorial_NS ${OACIS_IMAGE}
  sleep 20
  test `docker exec -it ${OACIS_CONTAINER_NAME} bash -c "test -f /home/oacis/samples/oacis_tutorial_NS.tar.bz2"; echo $?` -eq 0 -a \
    `docker exec -it ${OACIS_CONTAINER_NAME} bash -c "test -d /home/oacis/oacis/public/oacis_tutorial_NS"; echo $?` -eq 0 -a \
    `docker exec -it ${OACIS_CONTAINER_NAME} bash -c "test -d /home/oacis/oacis/public/Result_development/db/dump-20151112-1310"; echo $?` -eq 0 -a \
    `docker exec -it ${OACIS_CONTAINER_NAME} bash -c "test -d /home/oacis/oacis/public/Result_development/5625a5533939360088030000"; echo $?` -eq 0 -a \
    `docker exec -it ${OACIS_CONTAINER_NAME} bash -c "test -f /home/oacis/oacis/public/Result_development/work/nagel_schreckenberg_model/run.sh"; echo $?` -eq 0 -a \
    `docker exec -it ${OACIS_CONTAINER_NAME} bash -c "mongo --eval \"db = db.getSiblingDB('oacis_development'); printjson(db.simulators.findOne().name)\"" | tail -1 | tr -d '\r'` == '"Nagel_Schreckenberg"'
}

restore_tutorial_NS
rc=$?

exit $rc

