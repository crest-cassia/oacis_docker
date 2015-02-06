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
  mkdir ${WORKDIR}/.ssh # file permission is modified in vboxsf
  echo "================================================================"
  echo "create new data directories for ${PROJECT_NAME}"
fi

#create data container for boot2docker
dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-DATA[\ ]*$"`
if [ -z "$dockerps" ]
then
  echo "================================================================"
  echo "OACIS-${PROJECT_NAME}-DATA (data container) has not been created"
  echo "Would you create new data container? [y/n]"
  read ans
  if [ $ans="y" -o $ans="Y" -o $ans="yes" -o $ans="Yes" ]
  then
    docker run --entrypoint="echo" --name OACIS-${PROJECT_NAME}-DATA -v ${WORKDIR}/db:/home/oacis/db_backup -v ${WORKDIR}/Result_development:/home/oacis/oacis/public/Result_development -v ${WORKDIR}/work:/home/oacis/work -v ${WORKDIR}/.ssh:/home/oacis/.ssh_backup ${OACIS_IMAGE} "data container is created"
  fi

  if [ -f ${WORKDIR}/db/oacis_development.ns ]
  then
    echo "================================================================"
    echo "Old mongodb files exist in ./db/"
    echo "Would you restor mongodb files? [y/n]"
    read ans
    if [ $ans="y" -o $ans="Y" -o $ans="yes" -o $ans="Yes" ]
    then
      docker run -it --entrypoint="/bin/bash" --name OACIS-${PROJECT_NAME} --volumes-from OACIS-${PROJECT_NAME}-DATA ${OACIS_IMAGE} -c "/usr/bin/rsync -a /home/oacis/db_backup/ /home/oacis/db/; chown -R oacis:oacis /home/oacis/db;"
      docker rm OACIS-${PROJECT_NAME} > /dev/null
    fi
  fi

  if [ -f ${WORKDIR}/.ssh/id_rsa -o -f ${WORKDIR}/.ssh/authorized_keys ]
  then
    echo "================================================================"
    echo "ssh settings exist in ./.ssh/"
    echo "Would you restor ssh settings? [y/n]"
    read ans
    if [ $ans="y" -o $ans="Y" -o $ans="yes" -o $ans="Yes" ]
    then
      docker run -it --entrypoint="/bin/bash" --name OACIS-${PROJECT_NAME} --volumes-from OACIS-${PROJECT_NAME}-DATA ${OACIS_IMAGE} -c "/usr/bin/rsync -a /home/oacis/.ssh_backup/ /home/oacis/.ssh/; chown -R oacis:oacis /home/oacis/.ssh; chmod 600 /home/oacis/.ssh/authorized_keys; chmod 600 /home/oacis/.ssh/id_rsa"
      docker rm OACIS-${PROJECT_NAME} > /dev/null
    fi
  fi
fi

#run container
echo "================================================================"
docker run -it -p $PORT:3000 --name OACIS-${PROJECT_NAME} --volumes-from OACIS-${PROJECT_NAME}-DATA ${OACIS_IMAGE}
docker rm OACIS-${PROJECT_NAME} > /dev/null
exit 0
