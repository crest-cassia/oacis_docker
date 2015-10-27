#!/bin/bash

function initialize() {
  #verify arguments
  if [ $# -lt 1 ]
  then
    echo "usage $0 PROJECT_NAME [port]"
    exit -1
  fi
  PROJECT_NAME=${1%/}  # removing trailing slash
  PORT=${2-3000}
  OACIS_IMAGE=${OACIS_IMAGE-"oacis/oacis:latest"}
  MONGO_IMAGE="mongo:3.0.3"
  WORK_DIR=`pwd`/${PROJECT_NAME}
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

function check_old_container() {
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

function check_directory() {
  if [ -d ${WORK_DIR} ]
  then
    echo "Error: ${WORK_DIR} already exists."
    exit -1
  fi
}

function create_directory() {
  mkdir ${WORK_DIR}
  mkdir ${WORK_DIR}/Result_development
  mkdir ${WORK_DIR}/work
  echo "================================================================"
  echo "New data directories are created for ${PROJECT_NAME}"
}

function create_containers() {
  docker create --name OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE}
  echo "================================================================"
  echo "A new container named OACIS-${PROJECT_NAME}-MONGODB-DATA is created."

  docker create --name OACIS-${PROJECT_NAME}-MONGODB --volumes-from OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE}
  echo "================================================================"
  echo "A new container named OACIS-${PROJECT_NAME}-MONGODB is created."

  docker create -i -p $PORT:3000 --name OACIS-${PROJECT_NAME} --link OACIS-${PROJECT_NAME}-MONGODB:mongo -v /${WORK_DIR}/Result_development:/home/oacis/oacis/public/Result_development -v /${WORK_DIR}/work:/home/oacis/work ${OACIS_IMAGE}
  echo "================================================================"
  echo "A new container named OACIS-${PROJECT_NAME} is created."
}

function start_oacis() {
  echo "================================================================"
  docker start OACIS-${PROJECT_NAME}-MONGODB
  echo "container OACIS-${PROJECT_NAME}-MONGODB has started."

  docker start OACIS-${PROJECT_NAME}
  echo "container OACIS-${PROJECT_NAME} has started."
}

function wait_until_oacis_started() {
  while :
  do
    sleep 1
    last=`docker logs OACIS-${PROJECT_NAME} 2> /dev/null | tail -n 1`
    echo $last
    if [ "$last" = "booted" ]
    then
      break
    fi
  done
}

#main processes
initialize $@
check_ports
check_old_container
check_directory
create_directory
create_containers
start_oacis
wait_until_oacis_started

exit 0
