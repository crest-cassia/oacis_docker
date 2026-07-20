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
    echo "  --publish-port : publish OACIS port to external host"
    echo "  --no-ssh-agent : disable sharing ssh-agent of host OS"
    echo "  --image-tag OACIS_IMAGE_TAG (default: latest) : the tag name of OACIS image. Image 'oacis/oacis:<TAG>' is used."
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

# save the original user in case it is called as sudo
ORIG_USER=${SUDO_USER:-$USER}

# returns the state ("running", "exited", "created", ...) of a service's container
service_state() {
  docker compose ps -a --format json "$1" 2>/dev/null | grep -o '"State":"[a-z]*"' | head -1 | cut -d'"' -f4
}

# check the current status of the stack
ALL_PS_JSON=$(docker compose ps -a --format json)
RUNNING_PS_JSON=$(docker compose ps --format json)
NO_RECREATE=""
if [ -z "${ALL_PS_JSON}" ] || [ "${ALL_PS_JSON}" == '[]' ]; then
  echo "====== no container exists. starting a new stack ====="
elif [ "$(service_state oacis)" == "running" ]; then
  echo "====== container is already running ========"
  exit 1
elif [ -z "${RUNNING_PS_JSON}" ] || [ "${RUNNING_PS_JSON}" == '[]' ]; then
  echo "====== there is a stopped container ========"
  echo "====== Use ./oacis_start.sh to reboot ======"
  exit 1
else
  # e.g. a previous boot failed after mongo/redis came up (such as a
  # mongo-init failure): re-running `up` starts the missing services and
  # re-runs the idempotent mongo-init. --no-recreate guarantees that the
  # existing containers (and everything inside them) are left untouched.
  echo "====== partially running stack detected; converging it ====="
  NO_RECREATE="--no-recreate"
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
  cd $SCRIPT_DIR
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
  if ! docker compose -f docker-compose.yml -f docker-compose.agent.yml up -d ${NO_RECREATE}; then
    ./oacis_wait_healthy.sh mongo redis oacis || true
    exit 1
  fi
else
  if ! docker compose -f docker-compose.yml up -d ${NO_RECREATE}; then
    ./oacis_wait_healthy.sh mongo redis oacis || true
    exit 1
  fi
fi

set +x
./oacis_wait_healthy.sh oacis

# if dump file exists, prompt to run oacis_restore_db
if [ -e "Result/db_dump" ]; then
  echo
  echo "===== 'Result/db_dump' file is found. Run ./oacis_restore_db.sh to restore the database ===="
fi
