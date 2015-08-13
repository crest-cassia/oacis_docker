#!/bin/bash

function initialize() {
  #verify arguments
  if [ $# -lt 2 ]
  then
    echo "usage ./backpu_db.sh PROJECT_NAME /path/to/db_dump_dir/oacis_development"
    exit -1
  fi
  PROJECT_NAME=$1
  db_dump_dir=$2
  if [ ! -d $db_dump_dir ]
  then
    echo "No such directory exists \'$db_dump_dir\'"
    exit 0
  fi
  if [ "$(basename ${db_dump_dir})" != "oacis_development" ]
  then
    echo "Dirname $(basename ${db_dump_dir}) is not much to \`oacis_development\`. exit"
    exit 0
  fi
  backup_dir=$(cd ${db_dump_dir}; pwd)

  MONGO_IMAGE="mongo:3.0.3"
}

function find_and_create_mongodb_data_container() {
  dockerps=`docker ps -a | grep "OACIS-${PROJECT_NAME}-MONGODB-DATA[\ ]*$"`
  if [ -z "$dockerps" ]
  then
    docker create --name OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE}
    echo "================================================================"
    echo "A new mongo data container named OACIS-${PROJECT_NAME}-MONGODB-DATA is created"
  else
    echo "MongoDB data container named OACIS-${PROJECT_NAME}-MONGODB-DATA exists"
    echo "If you want to delete OACIS-${PROJECT_NAME}-MONGODB-DATA, run \`docker rm OACIS-${PROJECT_NAME}-MONGODB-DATA\`. exit"
    exit 0
  fi
}

function restore_mongo_data_container {
  echo "================================================================"
  echo "Restoring mongodb data..."
  docker run -d --name OACIS-${PROJECT_NAME}-MONGODB-TMP --volumes-from OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE}
  docker run -it --rm --entrypoint="bash" --name OACIS-${PROJECT_NAME}-MONGORESTORE --link OACIS-${PROJECT_NAME}-MONGODB-TMP:mongo -v $backup_dir:/db_backup --volumes-from OACIS-${PROJECT_NAME}-MONGODB-DATA ${MONGO_IMAGE} -c "mongorestore --db oacis_development -h mongo /db_backup"
  docker stop OACIS-${PROJECT_NAME}-MONGODB-TMP > /dev/null
  docker rm OACIS-${PROJECT_NAME}-MONGODB-TMP > /dev/null
}

#main processes
initialize $@
find_and_create_mongodb_data_container
restore_mongo_data_container
exit 0
