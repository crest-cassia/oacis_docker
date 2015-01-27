#!/bin/bash

if [ $# -lt 1 ]
then
  echo "usage ./run-oacis-docker.sh PROJECT_NAME {port}"
  exit -1
fi
PROJECT_NAME=$1
PORT=${2-3000}
OACIS_IMAGE="takeshiuchitane/oacis:Development"

dockerps=`docker ps -a | grep OACIS-${PROJECT_NAME}-DATA`
if [ ! -n "$dockerps" ]
then
  WORKDIR=`pwd`/${PROJECT_NAME}
  if [ ! -d ${WORKDIR} ]
  then
    mkdir ${WORKDIR}
    mkdir ${WORKDIR}/db
    mkdir ${WORKDIR}/Result_development
    mkdir ${WORKDIR}/work
    mkdir ${WORKDIR}/.ssh
    chmod 700 ${WORKDIR}/.ssh
    echo "create new data container for ${PROJECT_NAME}"
  fi
else
  echo "A container named ${PROJECT_NAME} exists."
  exit -1
fi

#check latest image
docker pull ${OACIS_IMAGE}
docker run -it -p $PORT:3000 --name OACIS-${PROJECT_NAME} -v ${WORKDIR}/db:/home/oacis/db -v ${WORKDIR}/Result_development:/home/oacis/oacis/public/Result_development -v ${WORKDIR}/work:/home/oacis/work -v ${WORKDIR}/.ssh:/home/oacis/.ssh ${OACIS_IMAGE}
docker rm OACIS-${PROJECT_NAME}
exit 0
