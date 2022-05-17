#!/bin/bash -eu

cd $(dirname $0)

# parse option
usage() {
    echo "Usage: ./oacis_terminate.sh [OPTIONS]"
    echo "  Remove the container. Once you removed, you cannot restart the container and the database will be lost."
    echo "  Make sure you have made a backup by './oacis_dump_db.sh' before running this command."
    echo "  'Result' directory, where your backup is made, will not be removed by this command."
    echo
    echo "Options:"
    echo "  -h, --help : show this message"
    echo "  -f, --force : do not ask if you made a backup"
    echo
    exit 1
}

FORCE_TERMINATE=0
while (( $# > 0 ))
do
  case $1 in
    -h | --help)
      usage
      exit 1
      ;;
    -f | --force)
      FORCE_TERMINATE=1
      shift
      ;;
    *)
      echo "[Error] invalid argument"
      usage
      exit 1
      ;;
  esac
done


if [ $FORCE_TERMINATE -eq 0 ]; then
  echo "The database will be lost by terminating the container."
  echo "Make sure you made a backup by './oacis_dump_db.sh' if you need."
  read -p "Are you sure you want to terminate the container? (y/[n]): " -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "==== termination aborted ===="
    exit 1
  fi
fi

set -x
docker compose down --volumes
