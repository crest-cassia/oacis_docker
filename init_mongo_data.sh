#!/bin/bash
# One-shot init container (see docker-compose.yml):
# 1. initiates the single-node replica set required by OACIS v4
#    (no-op when already initiated; an existing standalone data volume is
#    converted in place, data is preserved)
# 2. seeds the default Host documents (idempotent)
set -e

MONGO_URL="mongodb://mongo:27017/?directConnection=true"
db_name=oacis_development

# Overall deadline for the whole script. Without it, a mongod that never
# comes up (or never elects itself primary) would block this one-shot
# container forever, and thereby `docker compose up -d` (which waits for
# service_completed_successfully) and `docker compose wait mongo-init`
# (which has no timeout option) in the management scripts.
MONGO_INIT_TIMEOUT=${MONGO_INIT_TIMEOUT:-120}
DEADLINE=$((SECONDS + MONGO_INIT_TIMEOUT))
check_deadline() {
  if [ ${SECONDS} -ge ${DEADLINE} ]; then
    echo "mongo-init: timed out after ${MONGO_INIT_TIMEOUT}s $1" >&2
    exit 1
  fi
}

# wait for mongod to accept connections
until mongosh "${MONGO_URL}" --quiet --eval 'db.adminCommand("ping").ok' >/dev/null 2>&1
do
  check_deadline "waiting for mongod to accept connections"
  sleep 1
done

# initiate the replica set if not yet initiated
mongosh "${MONGO_URL}" --quiet --eval '
  try {
    rs.status();
  } catch (e) {
    if (e.codeName == "NotYetInitialized") {
      rs.initiate({_id: "rs0", members: [{_id: 0, host: "mongo:27017"}]});
    } else {
      throw e;
    }
  }'

# wait until the node has elected itself writable primary
until [ "$(mongosh "${MONGO_URL}" --quiet --eval 'db.hello().isWritablePrimary' 2>/dev/null)" = "true" ]
do
  check_deadline "waiting for the replica set to elect a writable primary"
  sleep 1
done

DB_URL="mongodb://mongo:27017/${db_name}"
if [ "$(mongosh "${DB_URL}" --quiet --eval 'db.hosts.countDocuments({"name": "localhost"});' | tail -1 | tr -d '\r')" == "0" ]
then
  mongosh "${DB_URL}" --quiet --eval 'db.hosts.insertOne({"status" : "enabled", "work_base_dir" : "~/oacis/public/Result_development/work/__work__", "mounted_work_base_dir" : "~/oacis/public/Result_development/work/__work__", "max_num_jobs" : 4, "polling_interval" : 5, "min_mpi_procs" : 1, "max_mpi_procs" : 1, "min_omp_threads" : 1, "max_omp_threads" : 1, "name" : "localhost"})'
fi
if [ "$(mongosh "${DB_URL}" --quiet --eval 'db.hosts.countDocuments({"name": "docker-host"});' | tail -1 | tr -d '\r')" == "0" ]
then
  mongosh "${DB_URL}" --quiet --eval 'db.hosts.insertOne({"status" : "enabled", "work_base_dir" : "~/oacis_work", "mounted_work_base_dir" : "", "max_num_jobs" : 1, "polling_interval" : 5, "min_mpi_procs" : 1, "max_mpi_procs" : 1, "min_omp_threads" : 1, "max_omp_threads" : 1, "name" : "docker-host"})'
fi
