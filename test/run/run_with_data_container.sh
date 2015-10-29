#!/bin/bash

. ./test/base.sh

function run_with_data_container() {
  mkdir .oacis_docker_tmp_dir
  echo "hello" > .oacis_docker_tmp_dir/aaa.txt
  docker create --name ${OACIS_DATA_CONTAINER_NAME} -v `pwd`/.oacis_docker_tmp_dir:/home/oacis/oacis/public/Result_development busybox
  docker run --name ${OACIS_CONTAINER_NAME} -p ${PORT}:3000 -d --volumes-from ${OACIS_DATA_CONTAINER_NAME} ${OACIS_IMAGE}
  sleep 5
  test $(echo `docker exec -it ${OACIS_CONTAINER_NAME} bash -c "cat /home/oacis/oacis/public/Result_development/aaa.txt"` | tr -d '\r') == "hello"
}

run_with_data_container
rc=$?

rm -rf .oacis_docker_tmp_dir

exit $rc
