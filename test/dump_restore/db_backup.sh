#!/bin/bash

. ./test/base.sh

function db_dump_restore() {
  mkdir .oacis_docker_tmp_dir
  docker create --name oacis-data -v `pwd`/.oacis_docker_tmp_dir:/home/oacis/oacis/public/Result_development busybox
  docker run --name oacis -p ${PORT}:3000 -d --volumes-from oacis-data ${OACIS_IMAGE}
  sleep 20
  datetime=`date +%Y%m%d-%H%M`
  docker exec -it oacis bash -c "cd /home/oacis/oacis/public/Result_development; if [ ! -d db ]; then mkdir db; fi; cd db; mongodump --db oacis_development; mv dump dump-$datetime; chown -R oacis:oacis /home/oacis/oacis/public/Result_development/db"
  test -d .oacis_docker_tmp_dir/db/dump-$datetime/oacis_development
}

db_dump_restore
rc=$?

rm -rf .oacis_docker_tmp_dir

exit $rc

