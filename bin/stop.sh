#!/bin/bash

function initialize() {
  #verify arguments
  if [ $# -lt 1 ]
  then
    echo "usage $0 PROJECT_NAME"
    exit -1
  fi
  PROJECT_NAME=${1%/}  # removing trailing slash
}

function check_running_containers() {
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

function stop_containers() {
  docker stop OACIS-${PROJECT_NAME}
  echo "container OACIS-${PROJECT_NAME} has stopped."
  docker stop OACIS-${PROJECT_NAME}-MONGODB
  echo "container OACIS-${PROJECT_NAME}-MONGODB has stopped."
}

#main processes
initialize $@
check_running_containers
stop_containers

exit 0

