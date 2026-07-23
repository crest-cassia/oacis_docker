#!/bin/bash

# Warn when the ssh-agent socket shared into the oacis container is not
# functional. Docker silently mounts an empty directory when the socket path
# does not exist on the docker host (e.g. colima started without
# '--ssh-agent'), so a broken agent is only noticed when an ssh connection
# to a remote host such as 'docker-host' fails.
#
# Non-fatal by design: it always exits 0. OACIS itself runs fine without an
# agent; only job submission to remote hosts needs it.

cd "$(dirname "$0")"

CONTAINER_ID=$(docker compose ps -q oacis 2>/dev/null)
if [ -z "${CONTAINER_ID}" ]; then
  exit 0
fi

# skip when the stack was created with --no-ssh-agent
# (docker-compose.agent.yml sets SSH_AUTH_SOCK in the container environment)
if ! docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "${CONTAINER_ID}" \
    | grep -q '^SSH_AUTH_SOCK='; then
  exit 0
fi

# run the check as the same uid the OACIS processes run under, so that
# permission problems on the socket are caught too
LOCAL_UID=$(sed -n 's/^LOCAL_UID=//p' .env 2>/dev/null | head -1)
EXEC_USER=${LOCAL_UID:+-u ${LOCAL_UID}}

# ssh-add exits 0 (keys listed) or 1 (agent reachable but has no keys);
# 2 means the agent socket does not work (missing, a directory, or stale).
# Other codes come from 'docker compose exec' itself (e.g. the container
# stopped in the meantime) and say nothing about the agent.
docker compose exec -T ${EXEC_USER} oacis ssh-add -l >/dev/null 2>&1
RC=$?

if [ "${RC}" -eq 0 ]; then
  exit 0
elif [ "${RC}" -eq 1 ]; then
  cat >&2 <<'EOS'
================================= WARNING =================================
The ssh-agent shared with the OACIS container holds no keys.
SSH connections to remote hosts (including 'docker-host') will fail with
public key authentication until a key is added.
  Fix: run 'ssh-add' on the host OS. No restart is required.
===========================================================================
EOS
elif [ "${RC}" -ne 2 ]; then
  echo "NOTE: could not check the ssh-agent in the OACIS container" \
       "('docker compose exec' failed with code ${RC})." >&2
else
  cat >&2 <<'EOS'
================================= WARNING =================================
The ssh-agent socket is not working inside the OACIS container.
SSH connections to remote hosts (including 'docker-host') will fail.

Possible causes and fixes:
  - colima: the VM is running without ssh-agent forwarding.
      Fix: colima stop && colima start --ssh-agent
           then restart the stack with ./oacis_start.sh
           (the containers are stopped when the colima VM stops)
  - the ssh-agent is not running on the host OS, or the stack was booted
    from a shell without SSH_AUTH_SOCK set.
      Fix: make sure 'ssh-add -l' works on the host, then reboot the stack.
  - to run OACIS without an agent on purpose, boot with --no-ssh-agent
    to silence this warning.
===========================================================================
EOS
fi
exit 0
