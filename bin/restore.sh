#!/bin/bash

function initialize() {
  #verify arguments
  if [ $# -lt 1 ]
  then
    echo "usage $0 PROJECT_NAME [PORT]"
    exit -1
  fi
  PROJECT_NAME=${1%/}  # removing trailing slash
  PORT=${2-3000}
  OACIS_IMAGE=${OACIS_IMAGE-"oacis/oacis:latest"}
  WORK_DIR=`pwd`/${PROJECT_NAME}
  DUMP_DIR=${WORK_DIR}/db/`cd ${WORK_DIR}/db; ls | grep dump | sort | tail -n 1`/oacis_development
  MONGO_IMAGE="mongo:3.0.3"
}

function check_ports() {
  ports=`docker ps -a -q | xargs docker inspect --format='{{ if index .HostConfig.PortBindings "3000/tcp" }}{{(index (index .HostConfig.PortBindings "3000/tcp") 0).HostPort}}{{ end }}' | sed '/^$/d'`
  for port in $ports
  do
    if [ $port -eq $PORT ]
    then
      echo "Error: The port number ${PORT} has been used. Try: \`$0 PROJECT_NAME [port]\`"
      exit -1
    fi
  done
}

function error_if_dump_dir_not_found() {
  if [ ! -d ${DUMP_DIR} ]
  then
    echo "Error: Directory ${DUMP_DIR} is not found."
    exit -1
  fi
}

function error_if_containers_exist() {
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    echo "================================================================"
    echo "Error: A container named OACIS-${PROJECT_NAME} exists."
    exit -1
  fi
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-MONGODB[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    echo "================================================================"
    echo "Error: A container named OACIS-${PROJECT_NAME}-MONGODB exists."
    exit -1
  fi
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-MONGODB-DATA[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    echo "================================================================"
    echo "Error: A container named OACIS-${PROJECT_NAME}-MONGODB-DATA exists."
    exit -1
  fi
}

function restore_mongo_data_container() {

  docker create --name OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE}
  docker run -d --name OACIS-${PROJECT_NAME}-MONGODB-TMP --volumes-from OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE}
  docker run -it --rm --entrypoint="bash" --name OACIS-${PROJECT_NAME}-MONGORESTORE --link OACIS-${PROJECT_NAME}-MONGODB-TMP:mongo -v /${DUMP_DIR}:/db_backup --volumes-from OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE} -c "mongorestore --db oacis_development -h mongo /db_backup"
  docker stop OACIS-${PROJECT_NAME}-MONGODB-TMP > /dev/null
  docker rm OACIS-${PROJECT_NAME}-MONGODB-TMP > /dev/null
}

function create_mongo_oacis_containers() {
  docker create --name OACIS-${PROJECT_NAME}-MONGODB --volumes-from OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE}
  echo "================================================================"
  echo "A new container named OACIS-${PROJECT_NAME}-MONGODB is created."

  docker create -i -p $PORT:3000 --name OACIS-${PROJECT_NAME} --link OACIS-${PROJECT_NAME}-MONGODB:mongo -v /${WORK_DIR}/Result_development:/home/oacis/oacis/public/Result_development -v /${WORK_DIR}/work:/home/oacis/work ${OACIS_IMAGE}
  echo "================================================================"
  echo "A new container named OACIS-${PROJECT_NAME} is created."
}

#main processes
initialize $@
check_ports
error_if_dump_dir_not_found
error_if_containers_exist
restore_mongo_data_container
create_mongo_oacis_containers
exit 0
