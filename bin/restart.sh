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

function error_if_containers_are_running() {
  dockerps=`docker ps | grep "OACIS-${PROJECT_NAME}[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    echo "================================================================"
    echo "Error: A container named OACIS-${PROJECT_NAME} is running."
    exit -1
  fi
  dockerps=`docker ps | grep "OACIS-${PROJECT_NAME}-MONGODB[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    echo "================================================================"
    echo "Error: A container named OACIS-${PROJECT_NAME}-MONGODB is running."
    exit -1
  fi
}

function error_if_containers_are_not_found() {
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}[\ ]*$"`
  if [ -z "$dockerps" ]
  then
    echo "================================================================"
    echo "Error: A container named OACIS-${PROJECT_NAME} is not found."
    exit -1
  fi
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-MONGODB[\ ]*$"`
  if [ -z "$dockerps" ]
  then
    echo "================================================================"
    echo "Error: A container named OACIS-${PROJECT_NAME}-MONGODB is not found."
    exit -1
  fi
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-MONGODB-DATA[\ ]*$"`
  if [ -z "$dockerps" ]
  then
    echo "================================================================"
    echo "Error: A container named OACIS-${PROJECT_NAME}-MONGODB-DATA is not found."
    exit -1
  fi
}

function error_if_dir_is_not_found() {
  if [ ! -d ${WORK_DIR} ]
  then
    echo "Error: Directory ${WORK_DIR} is not found."
    exit -1
  fi
}

function restart_container() {
  echo "Starting containers"
  docker start OACIS-${PROJECT_NAME}-MONGODB
  docker start OACIS-${PROJECT_NAME}
}

#main processes
initialize $@
error_if_containers_are_running
error_if_containers_are_not_found
error_if_dir_is_not_found
restart_container

exit 0

