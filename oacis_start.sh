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


# returns the state ("running", "exited", "created", ...) of a service's container
service_state() {
  docker compose ps -a --format json "$1" 2>/dev/null | grep -o '"State":"[a-z]*"' | head -1 | cut -d'"' -f4
}

COMPOSE_PS_JSON=$(docker compose ps -a --format json)
echo "${COMPOSE_PS_JSON}"
if [ -z "${COMPOSE_PS_JSON}" ] || [ "${COMPOSE_PS_JSON}" == '[]' ]; then
  echo "===== there is no container ============"
  exit 1
fi
if [ "$(service_state oacis)" == "running" ]; then
  echo "===== container is already running ====="
  exit 1
fi

# `start` is a no-op for services which are already running, so a
# partially running stack (e.g. after a failed boot) is handled too
if ! docker compose start mongo redis; then
  ./oacis_wait_healthy.sh mongo redis || true
  exit 1
fi

# Re-run the idempotent one-shot init: it initiates the replica set when
# necessary, and the mongo healthcheck (isWritablePrimary) cannot pass
# before that. --no-recreate/--no-deps keep the existing containers
# untouched.
if ! docker compose up -d --no-recreate --no-deps mongo-init; then
  echo "===== failed to start mongo-init ====="
  exit 1
fi
if ! docker compose wait mongo-init; then
  echo "===== mongo-init failed ====="
  docker compose logs --tail 50 mongo-init >&2 || true
  exit 1
fi

./oacis_wait_healthy.sh mongo redis
if ! docker compose start oacis; then
  ./oacis_wait_healthy.sh oacis || true
  exit 1
fi

./oacis_wait_healthy.sh oacis

# warn (non-fatal) when the shared ssh-agent socket does not work: the bind
# mount source is re-resolved on every container start, so the agent can
# break silently after a host reboot or a docker-VM restart even though the
# stack booted fine before
./oacis_check_ssh_agent.sh
