#!/bin/bash -eu

cd $(dirname $0)

# parse option
usage() {
    echo "Usage: ./oacis_shell.sh [OPTIONS]"
    echo "  Login to the container"
    echo
    echo "Options:"
    echo "  -h, --help: show this message"
    echo "  -r : root login"
    echo
    exit 1
}

ROOT_LOGIN=0
while (( $# > 0 ))
do
  case $1 in
    -h | --help)
      usage
      exit 1
      ;;
    -r)
      ROOT_LOGIN=1
      shift
      ;;
    *)
      echo "[Error] invalid argument"
      usage
      exit 1
      ;;
  esac
done


# call `exec`
if [ $ROOT_LOGIN -eq 1 ]; then
  set -x
  docker compose exec oacis bash -l
else
  set -x
  docker compose exec -u oacis oacis bash -l
fi
