#!/bin/bash -eu

cd $(dirname $0)

# parse option
usage() {
    echo "Usage: ./oacis_start.sh [OPTIONS]"
    echo "  Restart the stopped container"
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


COMPOSE_PS_JSON=$(docker compose ps -a --format json)
echo "${COMPOSE_PS_JSON}"
if [ "${COMPOSE_PS_JSON}" == '[]' ]; then
  echo "===== there is no container ============"
  exit 1
elif echo "${COMPOSE_PS_JSON}" | grep -q '"State":"running"'; then
  echo "===== container is already running ====="
  exit 1
elif echo "${COMPOSE_PS_JSON}" | grep -q '"State":"exited"'; then
  if ! docker compose start mongo redis; then
    ./oacis_wait_healthy.sh mongo redis || true
    exit 1
  fi
  ./oacis_wait_healthy.sh mongo redis
  if ! docker compose start oacis; then
    ./oacis_wait_healthy.sh oacis || true
    exit 1
  fi
else
  echo "unexpected status"
  exit 1
fi

./oacis_wait_healthy.sh oacis
