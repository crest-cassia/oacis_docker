#!/bin/bash

function initialize() {
  #verify arguments
  if [ $# -lt 1 ]
  then
    echo "usage ./run-oacis-docker.sh PROJECT_NAME {port}"
    exit -1
  fi
  PROJECT_NAME=$1
  PORT=${2-3000}
  OACIS_IMAGE=${OACIS_IMAGE-"oacis/oacis:latest"}
  MONGO_IMAGE="mongo:3.0.3"
  WORK_DIR=`pwd`/${PROJECT_NAME}
  if [ -d ${WORK_DIR} ]
  then
    MODE="restart"
  else
    MODE="create"
    echo "Would you create a new project [${PROJECT_NAME}]? [Y/n]"
    while :
    do
      read ans
      if [ "$ans" = "y" -o "$ans" = "Y" -o "$ans" = "yes" -o "$ans" = "Yes" -o "$ans" = "" ]
      then
        break
      elif [ "$ans" = "n" -o "$ans" = "N" -o "$ans" = "no" -o "$ans" = "No" ]
      then
        echo "Give up to create a new project. exit."
        exit -1
      else
        echo "your input is $ans"
        echo "Would you create a new project [${PROJECT_NAME}]? [Y/n]"
      fi
    done
  fi
}

function check_old_container() {
  dockerps=`docker ps | grep "OACIS-${PROJECT_NAME}[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    echo "================================================================"
    echo "A container named OACIS-${PROJECT_NAME} is running."
    echo "try: \"docker stop OACIS-${PROJECT_NAME}\"."
    echo "try: \"docker rm OACIS-${PROJECT_NAME}\"."
    exit -1
  fi
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    echo "================================================================"
    echo "A container named OACIS-${PROJECT_NAME} exists."
    echo "try: \"docker rm OACIS-${PROJECT_NAME}\"."
    exit -1
  fi
}

function find_and_crate_mongo_data_container {
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-MONGODB-DATA[\ ]*$"`
  if [ "$MODE" = "create" ]
  then
    if [ ! -z "$dockerps" ]
    then
      echo "================================================================"
      echo "Mongodb data container exists though project directories do not exist."
      echo "Check project name or try: \"docker rm OACIS-${PROJECT_NAME}-MONGODB-DATA; docker rm OACIS-${PROJECT_NAME}-DATA\"."
      exit -1
    fi
    docker create --name OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE}
    echo "================================================================"
    echo "A new container named OACIS-${PROJECT_NAME}-MONGODB-DATA is created."
  else
    if [ -z "$dockerps" ]
    then
      echo "================================================================"
      echo "Mongodb data container does not exist though project directories exist."
      echo "Create or restore a mongodb data container."
      echo "Would you create a new mongodb data container? [Y/n]"
      while :
      do
        read ans
        if [ "$ans" = "y" -o "$ans" = "Y" -o "$ans" = "yes" -o "$ans" = "Yes" -o "$ans" = "" ]
        then
          docker create --name OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE}
          echo "================================================================"
          echo "A new container named OACIS-${PROJECT_NAME}-MONGODB-DATA is created."
          break
        elif [ "$ans" = "n" -o "$ans" = "N" -o "$ans" = "no" -o "$ans" = "No" ]
        then
          echo "There is no mongodb data container. exit."
          exit -1
        else
          echo "your input is $ans"
          echo "Would you create a new mongodb data container? [Y/n]"
        fi
      done
    fi
  fi
}

function find_and_create_oacis_data_container() {
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-DATA[\ ]*$"`
  if [ "$MODE" = "create" ]
  then
    if [ ! -z "$dockerps" ]
    then
      echo "================================================================"
      echo "OACIS data container exists though project directories do not exist."
      echo "Check project name or try: \"docker rm OACIS-${PROJECT_NAME}-MONGODB-DATA; docker rm OACIS-${PROJECT_NAME}-DATA\"."
      exit -1
    fi
    docker create --name OACIS-${PROJECT_NAME}-DATA ${OACIS_IMAGE}
    echo "================================================================"
    echo "A new oacis data container named OACIS-${PROJECT_NAME}-DATA is created."
  else
    if [ -z "$dockerps" ]
    then
      echo "================================================================"
      echo "OACIS data container only including ssh settings does not exist."
      echo "Create or restore an OAICS data container. "
      echo "Would you create a new OACIS data container? [Y/n]"
      while :
      do
        read ans
        if [ "$ans" = "y" -o "$ans" = "Y" -o "$ans" = "yes" -o "$ans" = "Yes" -o "$ans" = "" ]
        then
          docker create --name OACIS-${PROJECT_NAME}-DATA ${OACIS_IMAGE}
          echo "================================================================"
          echo "A new oacis data container named OACIS-${PROJECT_NAME}-DATA is created."
          break
        elif [ "$ans" = "n" -o "$ans" = "N" -o "$ans" = "no" -o "$ans" = "No" ]
        then
          echo "There is no OACIS data container. exit."
          exit -1
        else
          echo "your input is $ans"
          echo "Would you create a new OACIS data container? [Y/n]"
        fi
      done
    fi
  fi
}

function find_and_create_data_folders() {
  if [ $MODE = "create" ]
  then
    mkdir ${WORK_DIR}
    mkdir ${WORK_DIR}/Result_development
    mkdir ${WORK_DIR}/work
    echo "================================================================"
    echo "New data directories are created for ${PROJECT_NAME}"
  fi
}

function start_oacis() {
  echo "================================================================"
  docker run -d --name OACIS-${PROJECT_NAME}-MONGODB --volumes-from OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE}
  docker run -it --rm -p $PORT:3000 --name OACIS-${PROJECT_NAME} --link OACIS-${PROJECT_NAME}-MONGODB:mongo --volumes-from OACIS-${PROJECT_NAME}-DATA -v /${WORK_DIR}/Result_development:/home/oacis/oacis/public/Result_development -v /${WORK_DIR}/work:/home/oacis/work ${OACIS_IMAGE}
  docker stop OACIS-${PROJECT_NAME}-MONGODB > /dev/null
  docker rm OACIS-${PROJECT_NAME}-MONGODB > /dev/null
}

#main processes
initialize $@
check_old_container
find_and_crate_mongo_data_container
find_and_create_oacis_data_container
find_and_create_data_folders
start_oacis

exit 0
