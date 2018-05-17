#!/bin/bash -x

#pre-processes
if [ ! ${LOCAL_GID:-1000} = `id -g oacis` ]; then
  groupmod -g ${LOCAL_GID:-1000} oacis
fi
if [ ! ${LOCAL_UID:-1000} = `id -u oacis` ]; then
  usermod -g ${LOCAL_GID:-1000} -u ${LOCAL_UID:-1000} oacis
  chown -R oacis:oacis /usr/local/bundle
  chown -R oacis:oacis /data/db
fi

#start mongod, redis and sshd
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

#waiting for mongod boot
until [ "$(mongo --eval 'printjson(db.serverStatus().ok)' | tail -1 | tr -d '\r')" == "1" ]
do
  sleep 1
  echo "waiting for mongod boot..."
done

function cleanup() {
  su - -c "echo terminating; cd ~/oacis; bundle exec rake daemon:stop" oacis
  kill $(ps -Af | grep [s]upervisord | awk '{print $2}')
  kill ${!}
}

trap cleanup SIGINT SIGTERM

db_name=oacis_development
if [ "$(mongo ${db_name} --eval 'printjson(db.hosts.count({"name": "localhost"}));' | tail -1 | tr -d '\r')" == "0" ]
then
  mongo ${db_name} --eval 'db.hosts.insert({"status" : "enabled", "port" : 22, "ssh_key" : "~/.ssh/id_rsa", "work_base_dir" : "~/oacis/public/Result_development/work/__work__", "mounted_work_base_dir" : "~/oacis/public/Result_development/work/__work__", "max_num_jobs" : 1, "polling_interval" : 5, "min_mpi_procs" : 1, "max_mpi_procs" : 1, "min_omp_threads" : 1, "max_omp_threads" : 1, "name" : "localhost", "hostname" : "localhost", "user" : "oacis"})'
fi

#run oacis
su - -c "\
  cd /home/oacis/oacis && \
  bundle exec rake daemon:restart && \
  if [ ! -f ~/.ssh/id_rsa ]; \
  then \
    echo -e \"\\n\" | ssh-keygen -N \"\" -f $HOME/.ssh/id_rsa && \
    cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys && \
    chmod 600 $HOME/.ssh/authorized_keys; \
  fi" \
  oacis

echo "==== OACIS READY ===="
tail -f /dev/null &
child=$!
wait "$child"

