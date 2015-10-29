#!/bin/bash

. ./test/base.sh

function db_dump_restore() {
  mkdir .oacis_docker_tmp_dir
  docker create --name ${OACIS_DATA_CONTAINER_NAME} -v `pwd`/.oacis_docker_tmp_dir:/home/oacis/oacis/public/Result_development busybox
  docker run --name ${OACIS_CONTAINER_NAME} -p ${PORT}:3000 -d --volumes-from ${OACIS_DATA_CONTAINER_NAME} ${OACIS_IMAGE}
  sleep 20
  datetime=`date +%Y%m%d-%H%M`
  docker exec -it ${OACIS_CONTAINER_NAME} bash -c "cd /home/oacis/oacis/public/Result_development; if [ ! -d db ]; then mkdir db; fi; cd db; mongodump --db oacis_development; mv dump dump-$datetime; chown -R oacis:oacis /home/oacis/oacis/public/Result_development/db"
  test -d .oacis_docker_tmp_dir/db/dump-$datetime/oacis_development
}

db_dump_restore
rc=$?

docker exec -it ${OACIS_CONTAINER_NAME} bash -c "chmod 777 -R /home/oacis/oacis/public/Result_development"
rm -rf .oacis_docker_tmp_dir

exit $rc

