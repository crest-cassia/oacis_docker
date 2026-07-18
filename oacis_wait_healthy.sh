#!/bin/bash -eu

cd "$(dirname "$0")"

HEALTH_TIMEOUT=${OACIS_HEALTH_TIMEOUT:-600}
POLL_INTERVAL=${OACIS_HEALTH_POLL_INTERVAL:-2}
LOG_LINES=${OACIS_HEALTH_LOG_LINES:-200}

if ! [[ "${HEALTH_TIMEOUT}" =~ ^[0-9]+$ ]] || [ "${HEALTH_TIMEOUT}" -eq 0 ]; then
  echo "OACIS_HEALTH_TIMEOUT must be a positive integer (seconds)." >&2
  exit 2
fi
if ! [[ "${POLL_INTERVAL}" =~ ^[0-9]+$ ]] || [ "${POLL_INTERVAL}" -eq 0 ]; then
  echo "OACIS_HEALTH_POLL_INTERVAL must be a positive integer (seconds)." >&2
  exit 2
fi
if ! [[ "${LOG_LINES}" =~ ^[0-9]+$ ]] || [ "${LOG_LINES}" -eq 0 ]; then
  echo "OACIS_HEALTH_LOG_LINES must be a positive integer." >&2
  exit 2
fi

if [ "$#" -eq 0 ]; then
  set -- oacis
fi

show_diagnostics() {
  echo
  echo "===== docker compose ps =====" >&2
  docker compose ps -a >&2 || true
  echo
  echo "===== recent service logs =====" >&2
  docker compose logs --tail "${LOG_LINES}" oacis mongo redis >&2 || true
}

fail() {
  echo "ERROR: $*" >&2
  show_diagnostics
  exit 1
}

SECONDS=0
echo "Waiting up to ${HEALTH_TIMEOUT}s for services to become healthy: $*"

while true; do
  all_healthy=true

  for service in "$@"; do
    container_id=$(docker compose ps -q "${service}")
    if [ -z "${container_id}" ]; then
      fail "No container found for service '${service}'."
    fi

    state=$(docker inspect --format '{{.State.Status}}' "${container_id}") \
      || fail "Could not inspect service '${service}'."
    health=$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "${container_id}") \
      || fail "Could not inspect health for service '${service}'."

    case "${state}:${health}" in
      running:healthy)
        ;;
      running:starting)
        all_healthy=false
        ;;
      running:unhealthy)
        fail "Service '${service}' is unhealthy."
        ;;
      running:none)
        fail "Service '${service}' has no healthcheck."
        ;;
      *)
        fail "Service '${service}' is not running (state=${state}, health=${health})."
        ;;
    esac
  done

  if [ "${all_healthy}" = true ]; then
    echo "Services are healthy: $*"
    exit 0
  fi

  if [ "${SECONDS}" -ge "${HEALTH_TIMEOUT}" ]; then
    fail "Timed out after ${HEALTH_TIMEOUT}s waiting for services: $*"
  fi

  sleep "${POLL_INTERVAL}"
done
