#!/bin/bash -eu

cd $(dirname $0)

# parse option
usage() {
    echo "Usage: ./oacis_dump_db.sh [OPTIONS]"
    echo "  Make a buckup file of mongodb used in OACIS container at 'Result/db_dump'"
    echo "  Once you ran this command, a complete backup of OACIS is stored under the 'Result/' directory."
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

set -x
docker compose exec -u oacis oacis /home/oacis/oacis/bin/oacis_dump_db
