#!/bin/bash -x

#pre-processes
chown -R oacis:oacis /home/oacis/oacis/public/Result_development
chown -R oacis:oacis /home/oacis/work; chown oacis:oacis /home/oacis/.ssh
chmod 700 /home/oacis/.ssh
mv /home/oacis/oacis/config/mongoid.yml /home/oacis/oacis/config/mongoid.yml.orig
sed -e s/localhost:27017/mongo:27017/g /home/oacis/oacis/config/mongoid.yml.orig > /home/oacis/oacis/config/mongoid.yml
chown oacis:oacis /home/oacis/oacis/config/mongoid.yml

#start ssh process
/usr/bin/supervisord

#run oacis
su - -c "cd ~/oacis; \
  bundle exec rake daemon:start; \
  if [ ! -f ~/.ssh/id_rsa ]; then echo -e \"\\n\" | ssh-keygen -N \"\" -f $HOME/.ssh/id_rsa; cat $HOME/.ssh/id_rsa.pub > $HOME/.ssh/authorized_keys; chmod 600 $HOME/.ssh/authorized_keys; fi" \
  oacis; su - oacis

#post-processes
su - -c "cd ~/oacis; bundle exec rake daemon:stop" oacis
su - -c "if [ -d /home/oacis/.ssh_backup ]; then rsync -a /home/oacis/.ssh/* /home/oacis/.ssh_backup/; fi" oacis
