#!/bin/bash

. ./test/base.sh

function db_dump_restore() {
  docker run --name oacis -p ${PORT}:3000 -d ${OACIS_IMAGE}
  sleep 20
  datetime=`date +%Y%m%d-%H%M`
  docker exec -it oacis bash -c "cd /home/oacis/oacis/public/Result_development; if [ ! -d db ]; then mkdir db; fi; cd db; mongodump --db oacis_development; mv dump dump-$datetime; chown -R oacis:oacis /home/oacis/oacis/public/Result_development/db"
  uid=`id -u`
  docker run -it --rm --entrypoint="bash" --volumes-from oacis -v `pwd`:/backup ${OACIS_IMAGE} -c "rsync -av /home/oacis/oacis/public/Result_development /backup/; chown -R $uid:$uid /backup/Result_development"
  test -d Result_development
}

db_dump_restore
rc=$?

rm -rf Result_development

exit $rc

