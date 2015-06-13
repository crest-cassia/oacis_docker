#!/bin/bash

if [ $# -lt 1 ]
then
  echo "usage ./run-oacis-docker.sh PROJECT_NAME {port}"
  exit -1
fi
PROJECT_NAME=$1
PORT=${2-3000}
OACIS_IMAGE="takeshiuchitane/oacis:Development"
MONGO_IMAGE="mongo:3.0.3"
#check latest image
docker pull ${OACIS_IMAGE}
docker pull ${MONGO_IMAGE}

dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}[\ ]*$"`
if [ -n "$dockerps" ]
then
  echo "================================================================"
  echo "A container named OACIS-${PROJECT_NAME} exists."
  exit -1
fi

WORKDIR=`pwd`/${PROJECT_NAME}
if [ ! -d ${WORKDIR} ]
then
  mkdir ${WORKDIR}
  mkdir ${WORKDIR}/db
  mkdir ${WORKDIR}/Result_development
  mkdir ${WORKDIR}/work
  mkdir ${WORKDIR}/.ssh
  chmod 700 ${WORKDIR}/.ssh
  echo "================================================================"
  echo "create new data directories for ${PROJECT_NAME}"
fi
dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-MONGODB[\ ]*$"`
dockerps_stop=`docker ps | grep "OACIS-${PROJECT_NAME}-MONGODB[\ ]*$"`
if [ -z "$dockerps" ]
then
  if [ -z "$dockerps_stop" ]
  then
    docker run -v ${WORKDIR}/db:/data/db -d --name OACIS-${PROJECT_NAME}-MONGODB ${MONGO_IMAGE}
    echo "================================================================"
    echo "run mongo container for ${PROJECT_NAME}"
  else
    docker start OACIS-${PROJECT_NAME}-MONGODB
    echo "================================================================"
    echo "start mongo container for ${PROJECT_NAME}"
  fi
fi

#run container
echo "================================================================"
docker run -it --rm -p $PORT:3000 --name OACIS-${PROJECT_NAME} --link OACIS-${PROJECT_NAME}-MONGODB:mongo -v ${WORKDIR}/Result_development:/home/oacis/oacis/public/Result_development -v ${WORKDIR}/work:/home/oacis/work -v ${WORKDIR}/.ssh:/home/oacis/.ssh ${OACIS_IMAGE}
docker stop OACIS-${PROJECT_NAME}-MONGODB > /dev/null
docker rm OACIS-${PROJECT_NAME}-MONGODB > /dev/null
exit 0
