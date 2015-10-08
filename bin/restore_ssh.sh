#!/bin/bash

function initialize() {
  #verify arguments
  if [ $# -lt 2 ]
  then
    echo "usage ./backpu_ssh.sh PROJECT_NAME /path/to/ssh_dump_dir"
    exit -1
  fi
  PROJECT_NAME=${1%/}
  ssh_dump_dir=$2
  if [ ! -d $ssh_dump_dir ]
  then
    echo "No such directory exists \'$ssh_dump_dir\'"
    exit 0
  fi
  backup_dir=$(cd ${ssh_dump_dir}; pwd)
  OACIS_IMAGE=${OACIS_IMAGE-"takeshiuchitane/oacis:latest"}
}

function find_and_create_ssh_config_container() {
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-DATA[\ ]*$"`
  if [ -z "$dockerps" ]
  then
    docker create --name OACIS-${PROJECT_NAME}-DATA ${OACIS_IMAGE}
    echo "================================================================"
    echo "A new OAICS data container OACIS-${PROJECT_NAME}-DATA is created"
  else
    echo "OACIS data container named OACIS-${PROJECT_NAME}-DATA exists"
    echo "If you want to delete OACIS-${PROJECT_NAME}-DATA, run \`docker rm OACIS-${PROJECT_NAME}-DATA\`. exit"
    exit 0
  fi
}

function restore_oacis_data_container() {
  echo "================================================================"
  echo "Restoring ssh data..."
  docker run -it --rm --entrypoint="bash" --name OACIS-${PROJECT_NAME}-DATA_RESTORE -v $backup_dir:/home/oacis/.ssh_backup --volumes-from OACIS-${PROJECT_NAME}-DATA ${OACIS_IMAGE} -c "rsync -a --delete /home/oacis/.ssh_backup/ /home/oacis/.ssh/; chown -R oacis:oacis /home/oacis/.ssh; chmod 600 /home/oacis/.ssh/authorized_keys; chmod 600 /home/oacis/.ssh/id_rsa"
}

#main processes
initialize $@
find_and_create_ssh_config_container
restore_oacis_data_container
exit 0
