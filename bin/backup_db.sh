#!/bin/bash

function initialize() {
  #verify arguments
  if [ $# -lt 1 ]
  then
    echo "usage ./backup.sh PROJECT_NAME"
    exit -1
  fi
  PROJECT_NAME=$1

  #pull images
  MONGO_IMAGE="mongo:3.0.3"

  datetime=`date +%Y%m%d-%H%M`
}

function create_backup_dir() {
  WORKDIR=`pwd`/${PROJECT_NAME}
  if [ ! -d ${WORKDIR} ]
  then
    mkdir  ${WORKDIR}
    if [ ! -d ${WORKDIR}/db ]
    then
      mkdir  ${WORKDIR}/db
    fi
  fi
}

function make_backup_db() {
  echo "making a backup of mongodb data files..."
  docker run -d --name OACIS-${PROJECT_NAME}-MONGODB-TMP --volumes-from OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE}
  docker run -it --rm --entrypoint="bash" --name OACIS-${PROJECT_NAME}-MONGOBACKUP --link OACIS-${PROJECT_NAME}-MONGODB-TMP:mongo -v /${WORKDIR}/db:/db_backup --volumes-from OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE} -c "cd /db_backup; mongodump --db oacis_development -h mongo; chmod -R 777 /db_backup/dump; mv /db_backup/dump /db_backup/dump-$datetime"
  docker stop OACIS-${PROJECT_NAME}-MONGODB-TMP > /dev/null
  docker rm OACIS-${PROJECT_NAME}-MONGODB-TMP > /dev/null
}

#main processes
initialize $@
create_backup_dir
make_backup_db

exit 0
