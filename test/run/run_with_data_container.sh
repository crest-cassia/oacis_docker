#!/bin/bash

. ./test/base.sh

function run_with_data_container() {
  echo "hello" > aaa.txt
  docker run --name oacis-mongo -d mongo:3.0.3
  docker create --name oacis-data -v `pwd`:/home/oacis/oacis/public/Result_development busybox
  docker run --name oacis -i -p ${PORT}:3000 --link oacis-mongo:mongo -d --volumes-from oacis-data ${OACIS_IMAGE}
  sleep 5
  test $(echo `docker exec -it oacis bash -c "cat /home/oacis/oacis/public/Result_development/aaa.txt"` | tr -d '\r') == "hello"
}

run_with_data_container
rc=$?

rm -f aaa.txt

exit $rc
