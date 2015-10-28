#!/bin/bash

. ./test/base.sh

function run_with_data_container() {
  echo "hello" > aaa.txt
  docker create --name oacis-data -v `pwd`:/home/oacis/oacis/public/Result_development busybox
  docker run --name oacis -i -p ${PORT}:3000 -d --volumes-from oacis-data ${OACIS_IMAGE}
  sleep 5
  test $(echo `docker exec -it oacis bash -c "cat /home/oacis/oacis/public/Result_development/aaa.txt"` | tr -d '\r') == "hello"
}

run_with_data_container
rc=$?

rm -f aaa.txt

exit $rc
