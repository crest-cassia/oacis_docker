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
}

function error_if_containers_are_running() {
  dockerps=`docker ps | grep "OACIS-${PROJECT_NAME}[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    echo "================================================================"
    echo "Error: A container named OACIS-${PROJECT_NAME} is running."
    echo "       Stop it before you delete."
    exit -1
  fi
  dockerps=`docker ps | grep "OACIS-${PROJECT_NAME}-MONGODB[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    echo "================================================================"
    echo "Error: A container named OACIS-${PROJECT_NAME}-MONGODB is running."
    echo "       Stop it before you delete."
    exit -1
  fi
}

function ask_if_you_are_sure() {
  echo "================================================================"
  echo "Deleting ${PROJECT_NAME} project."
  echo "Docker containers and work directory will be deleted."
  echo "Are you sure? [y/N]"
  read ans
  if [ "$ans" = "n" -o "$ans" = "N" -o "$ans" = "no" -o "$ans" = "No" -o "$ans" = "" ]
    exit -1
  fi
}

function delete_containers() {
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    docker rm OACIS-${PROJECT_NAME}
    echo "container OACIS-${PROJECT_NAME} has been removed"
  else
    echo "Warning: A container named OACIS-${PROJECT_NAME} is not found."
  fi
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-MONGODB[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    docker rm OACIS-${PROJECT_NAME}-MONGODB
    echo "container OACIS-${PROJECT_NAME}-MONGODB has been removed"
  else
    echo "Warning: A container named OACIS-${PROJECT_NAME}-MONGODB is not found."
  fi
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-MONGODB-DATA[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    docker rm OACIS-${PROJECT_NAME}-MONGODB-DATA
    echo "container OACIS-${PROJECT_NAME}-MONGODB-DATA has been removed"
  else
    echo "Warning: A container named OACIS-${PROJECT_NAME}-MONGODB-DATA is not found."
  fi

  echo "To delete all the data in the file system as well, delete ${WORK_DIR}"
}

#main processes
initialize $@
error_if_containers_are_running
ask_if_you_are_sure
delete_containers

exit 0

