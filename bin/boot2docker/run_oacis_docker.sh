#!/bin/sh

if [ $# -lt 1 ]
then
  echo "usage ./run-oacis-docker.sh PROJECT_NAME {port}"
  exit -1
fi
PROJECT_NAME=$1
PORT=${2-3000}
OACIS_IMAGE="takeshiuchitane/oacis:latest"
#check latest image
docker pull ${OACIS_IMAGE}

dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}[\ ]*$"`
if [ -n "$dockerps" ]
then
  echo "A container named ${PROJECT_NAME} exists."
  exit -1
fi

WORKDIR=`pwd`/${PROJECT_NAME}
if [ ! -d ${WORKDIR} ]
then
  mkdir ${WORKDIR}
  mkdir ${WORKDIR}/db
  mkdir ${WORKDIR}/Result_development
  mkdir ${WORKDIR}/work
  mkdir ${WORKDIR}/.ssh # file permission is modified in vboxsf
  echo "create new data directories for ${PROJECT_NAME}"
fi

#create data container for boot2docker
dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-DATA[\ ]*$"`
if [ -z "$dockerps" ]
then
  echo "create new data container for ${PROJECT_NAME}"
  docker run -it --entrypoint="/bin/bash" --name OACIS-${PROJECT_NAME}-DATA -v ${WORKDIR}/db:/home/oacis/db_backup -v ${WORKDIR}/Result_development:/home/oacis/oacis/public/Result_development -v ${WORKDIR}/work:/home/oacis/work -v ${WORKDIR}/.ssh:/home/oacis/.ssh_backup takeshiuchitane/oacis -c "/usr/bin/rsync -a /home/oacis/db_backup/ /home/oacis/db/; chown -R oacis:oacis /home/oacis/db; /usr/bin/rsync -a /home/oacis/.ssh_backup/ /home/oacis/.ssh/; chown -R oacis:oacis /home/oacis/.ssh; chmod 600 /home/oacis/.ssh/authorized_keys; chmod 600 /home/oacis/.ssh/id_rsa"
fi

#run container
docker run -it -p $PORT:3000 --name OACIS-${PROJECT_NAME} --volumes-from OACIS-${PROJECT_NAME}-DATA ${OACIS_IMAGE}
docker rm OACIS-${PROJECT_NAME}
exit 0
