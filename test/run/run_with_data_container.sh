#!/bin/bash

. ./test/base.sh

function run_with_data_container() {
  docker run --name oacis-mongo -d mongo:3.0.3
  docker create --name oacis-data -v `pwd`:/home/oacis/oacis/public/Result_development busybox
  docker run --name oacis -i -p ${PORT}:3000 --link oacis-mongo:mongo -d --volumes-from oacis-data ${OACIS_IMAGE}
  echo "hello" > aaa.txt
  sleep 15
  curl localhost:${PORT}
  test `docker exec -it oacis bash -c "cat /home/oacis/oacis/public/Result_development/aaa.txt"` == "hello"
}

run_with_data_container

