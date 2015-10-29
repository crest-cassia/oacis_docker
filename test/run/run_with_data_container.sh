#!/bin/bash

. ./test/base.sh

function run_with_data_container() {
  touch a.txt
  rm -f a.txt
  mkdir .oacis_docker_tmp_dir
  echo "hello" > .oacis_docker_tmp_dir/aaa.txt
  docker create --name ${OACIS_DATA_CONTAINER_NAME} -v `pwd`/.oacis_docker_tmp_dir:/home/oacis/oacis/public/Result_development busybox
  docker run --name ${OACIS_CONTAINER_NAME} -p ${PORT}:3000 -d --volumes-from ${OACIS_DATA_CONTAINER_NAME} ${OACIS_IMAGE}
  sleep 5
  test $(echo `docker exec -it ${OACIS_CONTAINER_NAME} bash -c "cat /home/oacis/oacis/public/Result_development/aaa.txt"` | tr -d '\r') == "hello"
  docker stop ${OACIS_CONTAINER_NAME}
}

run_with_data_container
rc=$?

# There is unclear reson why an error `rm: cannot remove ‘.oacis_docker_tmp_dir/aaa.txt’: Permission denied` occurs, skip it
rm -rf .oacis_docker_tmp_dir

exit $rc
