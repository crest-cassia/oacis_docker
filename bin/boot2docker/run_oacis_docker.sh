#!/bin/sh

if [ $# -lt 1 ]
then
  echo "usage ./run-oacis-docker.sh PROJECT_NAME {port}"
  exit -1
fi
PROJECT_NAME=$1
PORT=${2-3000}
OACIS_IMAGE="takeshiuchitane/oacis:latest"
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
  mkdir ${WORKDIR}/.ssh # file permission is modified in vboxsf
  echo "================================================================"
  echo "create new data directories for ${PROJECT_NAME}"
fi
dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-MONGODB[\ ]*$"`
dockerps_stop=`docker ps | grep "OACIS-${PROJECT_NAME}-MONGODB[\ ]*$"`
if [ -z "$dockerps" ]
then
  if [ -z "$dockerps_stop" ]
  then
    docker run -d --name OACIS-${PROJECT_NAME}-MONGODB ${MONGO_IMAGE}
    echo "================================================================"
    echo "run mongo container for ${PROJECT_NAME}"

    if [ -f ${WORKDIR}/db/oacis_development.ns ]
    then
      echo "================================================================"
      echo "Old mongodb files exist in ./db/"
      echo "Would you restor mongodb files? [y/n]"
      read ans
      if [ $ans="y" -o $ans="Y" -o $ans="yes" -o $ans="Yes" ]
      then
        docker stop OACIS-${PROJECT_NAME}-MONGODB
        docker run -it --rm --entrypoint="bash" --name OACIS-${PROJECT_NAME}-MONGORESTORE -v /${WORKDIR}/db:/mnt/db_backup --volumes-from OACIS-${PROJECT_NAME}-MONGODB ${OACIS_IMAGE} -c "rsync -a --delete /mnt/db_backup/ /data/db/"
        docker start OACIS-${PROJECT_NAME}-MONGODB
      fi
    fi
  else
    docker start OACIS-${PROJECT_NAME}-MONGODB
    echo "================================================================"
    echo "start mongo container for ${PROJECT_NAME}"
  fi
fi

#create data container for boot2docker
dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-DATA[\ ]*$"`
if [ -z "$dockerps" ]
then
  echo "================================================================"
  echo "create new data container OACIS-${PROJECT_NAME}-DATA"
  docker run --entrypoint="echo" --name OACIS-${PROJECT_NAME}-DATA -v /${WORKDIR}/Result_development:/home/oacis/oacis/public/Result_development -v /${WORKDIR}/work:/home/oacis/work -v /${WORKDIR}/.ssh:/home/oacis/.ssh_backup ${OACIS_IMAGE} "data container is created"

  if [ -f ${WORKDIR}/.ssh/id_rsa -o -f ${WORKDIR}/.ssh/authorized_keys ]
  then
    echo "================================================================"
    echo "ssh backup files exist in ./.ssh/"
    echo "Would you restor ssh settings? [y/n]"
    read ans
    if [ $ans="y" -o $ans="Y" -o $ans="yes" -o $ans="Yes" ]
    then
      docker run -it --rm --entrypoint="bash" --name OACIS-${PROJECT_NAME}-DATA_RESTORE --volumes-from OACIS-${PROJECT_NAME}-DATA ${OACIS_IMAGE} -c "rsync -a /home/oacis/.ssh_backup/ /home/oacis/.ssh/; chown -R oacis:oacis /home/oacis/.ssh; chmod 600 /home/oacis/.ssh/authorized_keys; chmod 600 /home/oacis/.ssh/id_rsa"
    fi
  fi
fi

#run container
echo "================================================================"
docker run -it --rm -p $PORT:3000 --name OACIS-${PROJECT_NAME} --link OACIS-${PROJECT_NAME}-MONGODB:mongo --volumes-from OACIS-${PROJECT_NAME}-DATA ${OACIS_IMAGE}
docker stop OACIS-${PROJECT_NAME}-MONGODB
docker run -it --rm --entrypoint="bash" --name OACIS-${PROJECT_NAME}-MONGORESTORE -v /${WORKDIR}/db:/mnt/db_backup --volumes-from OACIS-${PROJECT_NAME}-MONGODB ${OACIS_IMAGE} -c "rsync -a --delete /data/db/ /mnt/db_backup/"
exit 0
