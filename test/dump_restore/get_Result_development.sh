#!/bin/bash

. ./test/base.sh

function get_result_development() {
  docker run --name ${OACIS_CONTAINER_NAME} -p ${PORT}:3000 -d ${OACIS_IMAGE}
  sleep 20
  docker exec -it ${OACIS_CONTAINER_NAME} bash -c "cd /home/oacis/oacis/public/Result_development; if [ ! -d db ]; then mkdir db; fi; cd db; mongodump --db oacis_development; mv dump dump-`date +%Y%m%d-%H%M`; chown -R oacis:oacis /home/oacis/oacis/public/Result_development/db"
  docker cp ${OACIS_CONTAINER_NAME}:/home/oacis/oacis/public/Result_development .
  test -d Result_development/db
}

get_result_development
rc=$?

rm -rf Result_development

exit $rc

