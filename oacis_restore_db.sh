#!/bin/bash -eu

cd $(dirname $0)

# parse option
usage() {
    echo "Usage: ./oacis_restore_db.sh [OPTIONS]"
    echo "  Restore mongodb from the backup file 'Result/db_dump'"
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


if [ ! -e "Result/db_dump" ]; then
  echo "===== db_dump file 'Result/db_dump' is not found ====="
  exit 1
fi

set -x
docker compose exec -u oacis oacis /home/oacis/oacis/bin/oacis_restore_db
