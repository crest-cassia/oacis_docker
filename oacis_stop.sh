#!/bin/bash -eu

# parse option
usage() {
    echo "Usage: ./oacis_stop.sh [OPTIONS]"
    echo "  Stop the running container. You may restart the stopped container by './oacis_start.sh'"
    echo
    echo "Options:"
    echo "  -h, --help : show this message"
    echo
    exit 1
}

while (( $# > 0 ))
do
  case $1 in
    -h | --help)
      usage
      exit 1
      ;;
    *)
      echo "[Error] invalid argument"
      usage
      exit 1
      ;;
  esac
done

cd $(dirname $0)
set -x
docker compose stop -t 60

