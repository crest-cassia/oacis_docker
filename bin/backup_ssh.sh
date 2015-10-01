#!/bin/bash

function initialize() {
  #verify arguments
  if [ $# -lt 1 ]
  then
    echo "usage ./backup.sh PROJECT_NAME"
    exit -1
  fi
  PROJECT_NAME=$1
  OACIS_IMAGE=${OACIS_IMAGE-"takeshiuchitane/oacis:latest"}
  MONGO_IMAGE="mongo:3.0.3"
}

function create_backup_dir() {
  WORK_DIR=`pwd`/${PROJECT_NAME}
  if [ ! -d ${WORK_DIR} ]
  then
    mkdir  ${WORK_DIR}
    if [ ! -d ${WORK_DIR}/ssh ]
    then
      mkdir  ${WORK_DIR}/ssh
    fi
  fi
}

function make_backup_ssh() {
  echo "making a backup of ssh setting files..."
  docker run -it --rm --entrypoint="bash" --name OACIS-${PROJECT_NAME}-DATA_BACKUP -v /${WORK_DIR}/ssh:/home/oacis/ssh_backup --volumes-from OACIS-${PROJECT_NAME}-DATA ${OACIS_IMAGE} -c "rsync -a --delete /home/oacis/.ssh/ /home/oacis/ssh_backup/; chmod -R 777 /home/oacis/ssh_backup"
  echo "backup files are successfully saved to ${PROJECT_NAME}/ssh/"
}


#main processes
initialize $@
create_backup_dir
make_backup_ssh

exit 0
