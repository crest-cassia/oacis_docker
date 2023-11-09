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
    echo "  --publish-port : publish OACIS and jupyter port to external host"
    echo "  --no-ssh-agent : disable sharing ssh-agent of host OS"
    echo "  --image-tag OACIS_IMAGE_TAG (default: latest) : the tag name of OACIS image. Image 'oacis/oacis_jupyter:<TAG>' is used."
    echo "  --build-image OACIS_VERSION: don't pull the image but build a new image from Dockerfile"
    echo "                               specify the branch/tag name of OACIS ('develop', 'v3.10.0')"
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
    --publish-port)
      HOST_IP="0.0.0.0"
      shift
      ;;
    --no-ssh-agent)
      SSH_AUTH_SOCK=""
      shift
      ;;
    --image-tag)
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      OACIS_IMAGE_TAG=$2
      shift 2
      ;;
    --build-image)
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      OACIS_VERSION=$2
      shift 2
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
echo $COMPOSE_PS_JSON
if [ -z "${COMPOSE_PS_JSON}" ] || [ "${COMPOSE_PS_JSON}" == '[]' ]; then
  echo "====== no container is running. starting a new container ====="
else
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

set -ex

# build a docker image
if [ -n "${OACIS_VERSION}" ]; then
  if [ -z "${OACIS_IMAGE_TAG}" ]; then
    OACIS_IMAGE_TAG=${OACIS_VERSION}   #OACIS_IMAGE_TAG is determined by OACIS_VERSION unless explicitly given
  fi
  SCRIPT_DIR=$(cd $(dirname $0);pwd)
  cd $SCRIPT_DIR/oacis
  docker build . -t oacis/oacis:${OACIS_IMAGE_TAG} --build-arg OACIS_VERSION=${OACIS_VERSION}
  cd $SCRIPT_DIR/oacis_jupyter
  docker build . -t oacis/oacis_jupyter:${OACIS_IMAGE_TAG} --build-arg OACIS_VERSION=${OACIS_IMAGE_TAG}
  cd $SCRIPT_DIR
fi


# create ~/.ssh/config if it doesn't exist
# otherwise config file is mounted as a directory in container
if [ ! -f ~/.ssh/config ]; then
  touch ~/.ssh/config
  chmod 600 ~/.ssh/config
fi

# set SSH_AUTH_SOCK_APP
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

