#!/bin/bash -x

#pre-processes
if [ ! ${LOCAL_GID:-1000} = `id -g oacis` ]; then
  groupmod -g ${LOCAL_GID:-1000} oacis
  # this command can fail when the group already exists.
fi
if [ ! ${LOCAL_UID:-1000} = `id -u oacis` ]; then
  usermod -g ${LOCAL_GID:-1000} -u ${LOCAL_UID:-1000} oacis
fi

# mounted volumes are owned by root by default
chown -R oacis:$(id -g oacis) /home/oacis/oacis/public/Result_development
chown -R oacis:$(id -g oacis) /data/db

if [ -n "${SSH_AUTH_SOCK}" ]; then
  chown oacis:oacis ${SSH_AUTH_SOCK}
fi
if [ -n "${LOCAL_USER}" ]; then
  echo "User ${LOCAL_USER}" > /home/oacis/local_ssh_config
  chown oacis:oacis /home/oacis/local_ssh_config
fi

#start mongod, redis and sshd
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

function cleanup() {
  set -x
  su - -c "echo terminating; cd ~/oacis; bundle exec rake daemon:stop" oacis
  kill $(ps -Af | grep [s]upervisord | awk '{print $2}')
  kill ${!}
}

trap cleanup SIGINT SIGTERM

#run oacis
# pre-compile assets to accelerate the boot
su - -c "
  export RAILS_ENV=production && \
  export SSH_AUTH_SOCK=$SSH_AUTH_SOCK && \
  cd /home/oacis/oacis && \
  bin/rails assets:precompile && \
  bundle exec rake daemon:restart && \
  if [ ! -f ~/.ssh/id_rsa ]; \
  then \
    echo -e \"\\n\" | ssh-keygen -N \"\" -f $HOME/.ssh/id_rsa && \
    cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys && \
    chmod 600 $HOME/.ssh/authorized_keys; \
  fi" \
  oacis

set +x
echo "================= OACIS READY ================="
tail -f /dev/null &
child=$!
wait "$child"

