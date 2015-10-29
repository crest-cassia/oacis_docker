#!/bin/bash

. ./test/base.sh

function db_dump_restore() {
  tar jxvf ./samples/sample_backup.tar.bz2
  docker run --name ${OACIS_CONTAINER_NAME} -p ${PORT}:3000 -d ${OACIS_IMAGE}
  sleep 20
  docker cp `pwd`/sample_backup/Result_development ${OACIS_CONTAINER_NAME}:/home/oacis/oacis/public/
  docker exec -it ${OACIS_CONTAINER_NAME} bash -c "cd /home/oacis/oacis/public/Result_development/db/\`cd /home/oacis/oacis/public/Result_development/db; ls | grep dump | sort | tail -n 1\`/oacis_development; mongorestore --db oacis_development ."
  test `docker exec -it ${OACIS_CONTAINER_NAME} bash -c "mongo test --eval \"db = db.getSiblingDB('oacis_development'); printjson(db.hosts.findOne().name)\"" | tail -1 | sed -e "s/\"//g" -e "s/\r//"` == "localhost"
}

db_dump_restore
rc=$?

rm -rf sample_backup

exit $rc

