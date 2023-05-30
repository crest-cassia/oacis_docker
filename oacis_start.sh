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
  docker compose start
else
  echo "unexpected status"
  exit 1
fi

# show logs until OACIS is ready
if [ -e temp.pipe ]; then
  rm temp.pipe
fi
mkfifo temp.pipe
docker compose logs -f --since 0s > >(tee temp.pipe) 2> /dev/null &
trap "kill -9 $!" 1 2 3 15
# equivalent to `docker compose logs ... | tee temp.pipe`
# but we use process substitution to get the PID of `docker compose logs`
# in case we receive the signal, we kill `docker compose logs`
set +x
grep --line-buffered -m 1 "OACIS READY" > /dev/null < temp.pipe
# to stop `docker compose logs -f`, multiple signals are needed
# probably due to a bug in this command
while kill -0 $! 2> /dev/null; do
  kill -2 $!
  sleep 0.1
done
rm temp.pipe
