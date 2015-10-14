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

function error_if_containers_are_not_running() {
  dockerps=`docker ps | grep "OACIS-${PROJECT_NAME}[\ ]*$"`
  if [ -z "$dockerps" ]
  then
    echo "================================================================"
    echo "Error: A container named OACIS-${PROJECT_NAME} is not running."
    echo "       Stop it before you delete."
    exit -1
  fi
  dockerps=`docker ps | grep "OACIS-${PROJECT_NAME}-MONGODB[\ ]*$"`
  if [ -z "$dockerps" ]
  then
    echo "================================================================"
    echo "Error: A container named OACIS-${PROJECT_NAME}-MONGODB is not running."
    echo "       Stop it before you delete."
    exit -1
  fi
}

function launch_sh() {
  docker exec -it "OACIS-${PROJECT_NAME}" su - oacis -c 'cd /home/oacis/oacis; exec "bash"'
}

#main processes
initialize $@
error_if_containers_are_not_running
launch_sh

exit 0

