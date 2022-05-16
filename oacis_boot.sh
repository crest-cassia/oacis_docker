#!/bin/bash

cd $(dirname $0)

# parse option
usage() {
    echo "Usage: ./oacis_boot.sh [OPTIONS]"
    echo "  Run a OACIS container or restart the stopped container if exists."
    echo
    echo "Options:"
    echo "  -h, --help : show this message"
    echo "  -p PORT (default: 3000) : port used for OACIS"
    echo "  -j JUPYTER_PORT (default: 8888) : port used for Jupyter"
    echo "  --no-ssh-agent : disable sharing ssh-agent of host OS"
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
    -p)
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      OACIS_PORT=$2
      shift 2
      ;;
    -j)
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      JUPYTER_PORT=$2
      shift 2
      ;;
    --no-ssh-agent)
      SSH_AUTH_SOCK=""
      shift
      ;;
    *)
      echo "[Error] invalid argument"
      usage
      exit 1
      ;;
  esac
done


# check if contianer is already running
COMPOSE_PS_JSON=$(docker compose ps --format json)
if [ "${COMPOSE_PS_JSON}" != '[]' ]; then
  echo "${COMPOSE_PS_JSON}"
  if echo "${COMPOSE_PS_JSON}" | grep -q '"State":"running"'; then
    set +x
    echo "====== container is already running ========"
  elif echo "${COMPOSE_PS_JSON}" | grep -q '"State":"exited"'; then
    set +x
    echo "====== there is a stopped container ========"
    echo "====== Use ./oacis_start.sh to reboot ======"
  else
    echo "====== unexpected container status ========="
  fi
  exit 1
fi

# set SSH_AUTH_SOCK_APP
set -ex
if [ -n "${SSH_AUTH_SOCK}" ]; then
  if [ "$(uname)" == 'Darwin' ]; then  # Mac
    SSH_AUTH_SOCK_APP=/run/host-services/ssh-auth.sock
  elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
    SSH_AUTH_SOCK_APP=${SSH_AUTH_SOCK}
  else
    echo "Your platform ($(uname -a)) is not supported."
    exit 1
  fi
fi

# create `.env`
eval "echo \"$(cat dotenv_template)\"" > .env

# boot docker container
if [ -n "${SSH_AUTH_SOCK}" ]; then
  docker compose -f docker-compose.yml -f docker-compose.agent.yml up -d
else
  docker compose -f docker-compose.yml up -d
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

# if dump file exists, prompt to run oacis_restore_db
if [ -e "Result/db_dump" ]; then
  echo
  echo "===== 'Result/db_dump' file is found. Run ./oacis_restore_db.sh to restore the database ===="
fi