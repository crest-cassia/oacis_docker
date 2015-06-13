###################################
# OACIS Dockfile for Ubuntu Image #
###################################
FROM ubuntu:14.04
MAINTAINER "Takeshi Uchitane" <t.uchitane@gmail.com>

#Setup packages for oacis and its analyzers
RUN apt-get update && apt-get install -y openssh-server git build-essential curl gawk libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev supervisor; apt-get clean

#Create oacis user
RUN useradd -ms /bin/bash oacis
USER oacis
WORKDIR /home/oacis
ENV HOME /home/oacis

#Install rvm, ruby, bundler on oacia home directory
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3; \curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"; /bin/bash -l -c "rvm install 2.2"; echo "source $HOME/.rvm/scripts/rvm" >> $HOME/.bashrc; /bin/bash -l -c "gem install bundler"

#Install OACIS
WORKDIR /home/oacis
RUN git clone https://github.com/crest-cassia/oacis.git
WORKDIR /home/oacis/oacis
#ruby 2.2 is not suported on master branch oacis v1.15.1
#RUN git checkout master; git pull origin master; git pull origin master --tags; /bin/bash -l -c "bundle install --path=vendor/bundle"
RUN /bin/bash -l -c "bundle install --path=vendor/bundle"

USER root
ENV HOME /root

#Expose ports
EXPOSE 3000

#Create data volumes for OAICS
VOLUME ["/home/oacis/oacis/public/Result_development"]
VOLUME ["/home/oacis/work"]
VOLUME ["/home/oacis/.ssh"]

#Add config files for supervised to start up daemons
RUN if [ ! -d /var/run/sshd ]; then mkdir /var/run/sshd; fi; echo "[program:sshd]" > /etc/supervisor/conf.d/sshd.conf && echo "command=/usr/sbin/sshd -D" >> /etc/supervisor/conf.d/sshd.conf && echo "autostart=true" >> /etc/supervisor/conf.d/sshd.conf && echo "autorestart=true" >> /etc/supervisor/conf.d/sshd.conf

#Start OACIS
ENV HOME /home/oacis
#Start mongodb daemon and OACIS daemons.
#When you stop the container (run exit), OACIS daemons and mongodb process are going to stop automatically
ENTRYPOINT chown -R oacis:oacis /home/oacis/oacis/public/Result_development; chown -R oacis:oacis /home/oacis/work; chown oacis:oacis /home/oacis/.ssh; chmod 700 /home/oacis/.ssh; /usr/bin/supervisord; mv /home/oacis/oacis/config/mongoid.yml /home/oacis/oacis/config/mongoid.yml.orig; sed -e s/localhost:27017/mongo:27017/g /home/oacis/oacis/config/mongoid.yml.orig > /home/oacis/oacis/config/mongoid.yml; chown oacis:oacis /home/oacis/oacis/config/mongoid.yml; su - -c "cd ~/oacis; bundle exec rake daemon:start; if [ ! -f ~/.ssh/id_rsa ]; then echo -e \"\\n\" | ssh-keygen -N \"\" -f $HOME/.ssh/id_rsa; cat $HOME/.ssh/id_rsa.pub > $HOME/.ssh/authorized_keys; chmod 600 $HOME/.ssh/authorized_keys; fi" oacis; su - oacis; su - -c "cd ~/oacis; bundle exec rake daemon:stop" oacis; su - -c "if [ -d /home/oacis/.ssh_backup ]; then rsync -a /home/oacis/.ssh/* /home/oacis/.ssh_backup/; fi" oacis
