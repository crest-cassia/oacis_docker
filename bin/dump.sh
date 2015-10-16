#!/bin/bash

function initialize() {
  #verify arguments
  if [ $# -lt 1 ]
  then
    echo "usage $0 PROJECT_NAME"
    exit -1
  fi
  PROJECT_NAME=${1%/}  # removing trailing slash
  WORK_DIR=`pwd`/${PROJECT_NAME}
  MONGO_IMAGE="mongo:3.0.3"
}

function error_if_containers_are_not_running() {
  dockerps=`docker ps | grep "OACIS-${PROJECT_NAME}[\ ]*$"`
  if [ -z "$dockerps" ]
  then
    echo "================================================================"
    echo "Error: A container named OACIS-${PROJECT_NAME} is not running."
    exit -1
  fi
  dockerps=`docker ps | grep "OACIS-${PROJECT_NAME}-MONGODB[\ ]*$"`
  if [ -z "$dockerps" ]
  then
    echo "================================================================"
    echo "Error: A container named OACIS-${PROJECT_NAME}-MONGODB is not running"
    exit -1
  fi
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-MONGODB-DATA[\ ]*$"`
  if [ -z "$dockerps" ]
  then
    echo "================================================================"
    echo "Error: A container named OACIS-${PROJECT_NAME}-MONGODB-DATA is not found"
    exit -1
  fi
}

function check_directory_exists() {
  if [ ! -d ${WORK_DIR} ]
  then
    echo "Error: ${WORK_DIR} is not found."
    exit -1
  fi
}

function dump_mongodb() {
  uid=`id -u`
  datetime=`date +%Y%m%d-%H%M`
  MONGO_IMAGE="mongo:3.0.3"
  docker create --name OACIS-${PROJECT_NAME}-MONGODB-DATA-TMP -v /${WORK_DIR}/db:/db_backup ${MONGO_IMAGE}
  if [ "$OS" = "windows_NT" ]
  then
    winpty docker run -it --rm --entrypoint="bash" --name OACIS-${PROJECT_NAME}-MONGOBACKUP --link OACIS-${PROJECT_NAME}-MONGODB:mongo --volumes-from OACIS-${PROJECT_NAME}-MONGODB-DATA-TMP ${MONGO_IMAGE} -c "cd /db_backup; mongodump --db oacis_development -h mongo; chown -R $uid:$uid /db_backup; mv /db_backup/dump /db_backup/dump-$datetime"
  else
    docker run -it --rm --entrypoint="bash" --name OACIS-${PROJECT_NAME}-MONGOBACKUP --link OACIS-${PROJECT_NAME}-MONGODB:mongo --volumes-from OACIS-${PROJECT_NAME}-MONGODB-DATA-TMP ${MONGO_IMAGE} -c "cd /db_backup; mongodump --db oacis_development -h mongo; chown -R $uid:$uid /db_backup; mv /db_backup/dump /db_backup/dump-$datetime"
  fi
  docker rm OACIS-${PROJECT_NAME}-MONGODB-DATA-TMP > /dev/null
}

#main processes
initialize $@
error_if_containers_are_not_running
check_directory_exists
dump_mongodb

exit 0

