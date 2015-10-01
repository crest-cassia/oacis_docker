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
  OACIS_IMAGE=${OACIS_IMAGE-"takeshiuchitane/oacis:latest"}
  MONGO_IMAGE="mongo:3.0.3"
  #check latest image
  docker pull ${OACIS_IMAGE}
}

function check_old_container() {
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    echo "================================================================"
    echo "A container named OACIS-${PROJECT_NAME} exists."
    echo "try: \"docker rm OACIS-${PROJECT_NAME}\"."
    exit -1
  fi
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}[\ ]*$"`
  if [ -n "$dockerps" ]
  then
    echo "================================================================"
    echo "A container named OACIS-${PROJECT_NAME} is running."
    echo "try: \"docker stop OACIS-${PROJECT_NAME}\"."
    echo "try: \"docker rm OACIS-${PROJECT_NAME}\"."
    exit -1
  fi
}

function find_and_create_data_folders() {
  WORK_DIR=`pwd`/${PROJECT_NAME}
  if [ ! -d ${WORK_DIR} ]
  then
    mkdir ${WORK_DIR}
    mkdir ${WORK_DIR}/Result_development
    mkdir ${WORK_DIR}/work
    echo "================================================================"
    echo "New data directories are created for ${PROJECT_NAME}"
  fi
}

function find_and_crate_mongo_data_container {
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-MONGODB-DATA[\ ]*$"`
  if [ -z "$dockerps" ]
  then
    echo "================================================================"
    echo "Mongodb data container does not exist"
    echo "Would you create a new mongodb data container? [y/n]"
    while :
    do
      read ans
      if [ "$ans" = "y" -o "$ans" = "Y" -o "$ans" = "yes" -o "$ans" = "Yes" ]
      then
        docker create --name OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE}
        echo "================================================================"
        echo "A new container named OACIS-${PROJECT_NAME}-MONGODB-DATA is created."
        break
      elif [ "$ans" = "n" -o "$ans" = "N" -o "$ans" = "no" -o "$ans" = "No" ]
      then
        echo "There is no mongodb data container."
        echo "Create or restore a mongodb data container. exit."
        exit 0
      else
        echo "your input is $ans"
        echo "Would you create a new mongodb data container? [y/n]"
      fi
    done
  fi
}

function find_and_create_oacis_data_container() {
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-DATA[\ ]*$"`
  if [ -z "$dockerps" ]
  then
    echo "================================================================"
    echo "OACIS data container does not exist"
    echo "Would you create a new OACIS data container? [y/n]"
    while :
    do
      read ans
      if [ "$ans" = "y" -o "$ans" = "Y" -o "$ans" = "yes" -o "$ans" = "Yes" ]
      then
        docker run --entrypoint="echo" --name OACIS-${PROJECT_NAME}-DATA ${OACIS_IMAGE} "data container is created"
        echo "================================================================"
        echo "A new oacis data container named OACIS-${PROJECT_NAME}-DATA is created."
        break
      elif [ "$ans" = "n" -o "$ans" = "N" -o "$ans" = "no" -o "$ans" = "No" ]
      then
        echo "There is no OACIS data container."
        echo "Create or restore an OAICS data container. exit."
        exit 0
      else
        echo "your input is $ans"
        echo "Would you restor ssh settings? [y/n]"
      fi
    done
  fi
}

function start_oacis() {
  echo "================================================================"
  docker run -d --name OACIS-${PROJECT_NAME}-MONGODB --volumes-from OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE}
  docker run -it --rm -p $PORT:3000 --name OACIS-${PROJECT_NAME} --link OACIS-${PROJECT_NAME}-MONGODB:mongo --volumes-from OACIS-${PROJECT_NAME}-DATA -v /${WORK_DIR}/Result_development:/home/oacis/oacis/public/Result_development -v /${WORK_DIR}/work:/home/oacis/work ${OACIS_IMAGE}
  docker stop OACIS-${PROJECT_NAME}-MONGODB > /dev/null
  docker rm OACIS-${PROJECT_NAME}-MONGODB > /dev/null
}

function make_backup() {
  echo "Would you make backup of ssh setting files? [y/n]"
  while :
  do
    read ans
    if [ "$ans" = "y" -o "$ans" = "Y" -o "$ans" = "yes" -o "$ans" = "Yes" ]
    then
      echo "making a backup of ssh setting files..."
      backup_script=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)/backup_ssh.sh
      $backup_script $PROJECT_NAME
      break
    elif [ "$ans" = "n" -o "$ans" = "N" -o "$ans" = "no" -o "$ans" = "No" ]
    then
      echo "skip making a backup of ssh setting files."
      break
    else
      echo "your input is $ans"
      echo "Would you make backup of ssh setting files? [y/n]"
    fi
  done

  echo "Would you make backup of mongodb data files? [y/n]"
  while :
  do
    read ans
    if [ "$ans" = "y" -o "$ans" = "Y" -o "$ans" = "yes" -o "$ans" = "Yes" ]
    then
      backup_script=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)/backup_db.sh
      $backup_script $PROJECT_NAME
      break
    elif [ "$ans" = "n" -o "$ans" = "N" -o "$ans" = "no" -o "$ans" = "No" ]
    then
      echo "skip making a backup of mongodb data files."
      break
    else
      echo "your input is $ans"
      echo "Would you make backup of mongodb data files? [y/n]"
    fi
  done
}

#main processes
initialize $@
check_old_container
find_and_create_data_folders
find_and_crate_mongo_data_container
find_and_create_oacis_data_container
start_oacis
make_backup

exit 0
