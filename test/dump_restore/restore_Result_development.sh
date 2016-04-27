#!/bin/bash

. ./test/base.sh

function restore_result_development() {
  tar jxvf ./test/sample_backup_data.tar.bz2
  docker create --name ${OACIS_CONTAINER_NAME} -p ${PORT}:3000 ${OACIS_IMAGE}
  docker cp `pwd`/sample_backup_data/Result_development ${OACIS_CONTAINER_NAME}:/home/oacis/oacis/public/
  docker start ${OACIS_CONTAINER_NAME}
  sleep 20
  docker exec -it ${OACIS_CONTAINER_NAME} bash -c "cd /home/oacis/oacis/public/Result_development/db/\`cd /home/oacis/oacis/public/Result_development/db; ls | grep dump | sort | tail -n 1\`/oacis_development; mongorestore --db oacis_development ."
  test `docker exec -it ${OACIS_CONTAINER_NAME} bash -c "mongo --eval \"db = db.getSiblingDB('oacis_development'); printjson(db.hosts.findOne().name)\"" | tail -1 | tr -d '\r'` == '"localhost"'
}

restore_result_development
rc=$?

docker exec -it ${OACIS_CONTAINER_NAME} bash -c "chmod 777 -R /home/oacis/oacis/public/Result_development"
rm -rf sample_backup

exit $rc

