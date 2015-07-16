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

  #pull images
  OACIS_IMAGE="takeshiuchitane/oacis:latest"
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
}

function find_and_create_data_folders() {
  WORKDIR=`pwd`/${PROJECT_NAME}
  if [ ! -d ${WORKDIR} ]
  then
    mkdir ${WORKDIR}
    mkdir ${WORKDIR}/db
    mkdir ${WORKDIR}/Result_development
    mkdir ${WORKDIR}/.ssh
    mkdir ${WORKDIR}/work
    echo "================================================================"
    echo "Create new data directories for ${PROJECT_NAME}"
  else
    echo "================================================================"
    echo "Data directories for ${PROJECT_NAME} exist."
  fi
}

function find_and_crate_mongo_data_container {
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-MONGODB-DATA[\ ]*$"`
  if [ -z "$dockerps" ]
  then
    docker create --name OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE}
    echo "================================================================"
    echo "Create a new mongo data container OACIS-${PROJECT_NAME}-MONGODB-DATA"

    if [ -f ${WORKDIR}/db/db.tar.bz2 ]
    then
      echo "================================================================"
      echo "Mongodb backup files exist in ./db/"
      echo "Would you restor mongodb data files? [y/n]"
      while :
      do
        read ans
        if [ "$ans" = "y" -o "$ans" = "Y" -o "$ans" = "yes" -o "$ans" = "Yes" ]
        then
          docker run -it --rm --entrypoint="bash" --name OACIS-${PROJECT_NAME}-MONGORESTORE -v /${WORKDIR}/db:/db_backup --volumes-from OACIS-${PROJECT_NAME}-MONGODB-DATA ${OACIS_IMAGE} -c "cd /; tar jxf /db_backup/db.tar.bz2"
          break
        elif [ "$ans" = "n" -o "$ans" = "N" -o "$ans" = "no" -o "$ans" = "No" ]
        then
          echo "skip to restore mongodb data files from backup."
          break
        else
          echo "your input is $ans"
          echo "Would you restor mongodb data files? [y/n]"
        fi
      done
    fi
  fi
}

function find_and_create_oacis_data_container() {
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-DATA[\ ]*$"`
  if [ -z "$dockerps" ]
  then
    echo "================================================================"
    echo "create a new oacis data container OACIS-${PROJECT_NAME}-DATA"
    docker run --entrypoint="echo" --name OACIS-${PROJECT_NAME}-DATA -v /${WORKDIR}/Result_development:/home/oacis/oacis/public/Result_development -v /${WORKDIR}/work:/home/oacis/work ${OACIS_IMAGE} "data container is created"

    if [ -f ${WORKDIR}/.ssh/id_rsa -o -f ${WORKDIR}/.ssh/authorized_keys ]
    then
      echo "================================================================"
      echo "ssh backup files exist in ./.ssh/"
      echo "Would you restor ssh settings? [y/n]"
      while :
      do
        read ans
        if [ "$ans" = "y" -o "$ans" = "Y" -o "$ans" = "yes" -o "$ans" = "Yes" ]
        then
          docker run -it --rm --entrypoint="bash" --name OACIS-${PROJECT_NAME}-DATA_RESTORE -v /${WORKDIR}/.ssh:/home/oacis/.ssh_backup --volumes-from OACIS-${PROJECT_NAME}-DATA ${OACIS_IMAGE} -c "rsync -a --delete /home/oacis/.ssh_backup/ /home/oacis/.ssh/; chown -R oacis:oacis /home/oacis/.ssh; chmod 600 /home/oacis/.ssh/authorized_keys; chmod 600 /home/oacis/.ssh/id_rsa"
          break
        elif [ "$ans" = "n" -o "$ans" = "N" -o "$ans" = "no" -o "$ans" = "No" ]
        then
          echo "skip to restore ssh setting from backup."
          break
        else
          echo "your input is $ans"
          echo "Would you restor ssh settings? [y/n]"
        fi
      done
    fi
  fi
}

function star_oacis() {
  echo "================================================================"
  docker run -d --name OACIS-${PROJECT_NAME}-MONGODB --volumes-from OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE}
  docker run -it --rm -p $PORT:3000 --name OACIS-${PROJECT_NAME} --link OACIS-${PROJECT_NAME}-MONGODB:mongo --volumes-from OACIS-${PROJECT_NAME}-DATA ${OACIS_IMAGE}
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
      echo "start to make a backup of ssh setting files."
      docker run -it --rm --entrypoint="bash" --name OACIS-${PROJECT_NAME}-DATA_BACKUP -v /${WORKDIR}/.ssh:/home/oacis/.ssh_backup --volumes-from OACIS-${PROJECT_NAME}-DATA ${OACIS_IMAGE} -c "rsync -a --delete /home/oacis/.ssh/ /home/oacis/.ssh_backup/"
      break
    elif [ "$ans" = "n" -o "$ans" = "N" -o "$ans" = "no" -o "$ans" = "No" ]
    then
      echo "skip to make a backup of ssh setting files."
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
      echo "start to make a backup of mongodb data files."
      docker run -it --rm --entrypoint="bash" --name OACIS-${PROJECT_NAME}-MONGO_BACKUP -v /${WORKDIR}/db:/db_backup --volumes-from OACIS-${PROJECT_NAME}-MONGODB-DATA ${OACIS_IMAGE} -c "if [ -f /db_backup/db.tar.bz2 ]; then rm /db_backup/db.tar.bz2; fi; tar jcf /db_backup/db.tar.bz2 /data/db > /dev/null 2>&1; chmod 777 /db_backup/db.tar.bz2"
      break
    elif [ "$ans" = "n" -o "$ans" = "N" -o "$ans" = "no" -o "$ans" = "No" ]
    then
      echo "skip to make a backup of mongodb data files."
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
star_oacis
make_backup

exit 0
