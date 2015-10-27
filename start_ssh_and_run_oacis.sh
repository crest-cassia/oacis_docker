#!/bin/bash -x

#pre-processes
chown -R 999:999 /data/db
chown -R oacis:oacis /home/oacis/oacis/public/Result_development

#start ssh process
/usr/bin/supervisord

function cleanup() {
  su - -c "echo terminating; cd ~/oacis; bundle exec rake daemon:stop" oacis
}

trap cleanup SIGINT SIGTERM

#run oacis
su - -c "\
  cd ~/oacis; \
  bundle exec rake daemon:start; \
  if [ ! -f ~/.ssh/id_rsa ]; \
  then \
    echo -e \"\\n\" | ssh-keygen -N \"\" -f $HOME/.ssh/id_rsa; \
    cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys; \
    chmod 600 $HOME/.ssh/authorized_keys; \
  fi; \
  while true; do sleep 1; done" \
  oacis &

child=$!
wait "$child"
