#############################
# OACIS Dockfile for Ubuntu #
#############################
FROM ubuntu
MAINTAINER "Takeshi Uchitane" <t.uchitane@gmail.com>

#Setup packages for oacis and its analyzers
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10; echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list
RUN apt-get update && apt-get install -y openssh-server git build-essential curl mongodb-org gawk libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev supervisor

#Create oacis user
RUN adduser --disabled-password --gecos "" --shell /bin/bash oacis
USER oacis
WORKDIR /home/oacis
ENV HOME /home/oacis

#Install rvm, ruby, bundler on oacia home directory
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN \curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.0.0"
RUN echo "source $HOME/.rvm/scripts/rvm" >> $HOME/.bashrc
RUN /bin/bash -l -c "gem install bundler"

#Install OACIS
WORKDIR /home/oacis
RUN git clone https://github.com/crest-cassia/oacis.git
WORKDIR /home/oacis/oacis
RUN git checkout master
RUN git pull origin master
RUN git pull origin master --tags
RUN /bin/bash -l -c "bundle install --path=vendor/bundle"

USER root
#Setting up packages for analyzers
#You can add any packages.
RUN apt-get update && apt-get install -y r-base gnuplot
#Clean up
RUN apt-get clean

#Expose ports
EXPOSE 3000

#Create data volumes for OAICS
VOLUME ["/data/db"]
VOLUME ["/home/oacis/oacis/public/Result_development"]
RUN chown oacis:oacis /home/oacis/oacis/public/Result_development
VOLUME ["/home/oacis/work"]
RUN chown oacis:oacis /home/oacis/work
VOLUME ["/home/oacis/.ssh"]
RUN chown oacis:oacis /home/oacis/.ssh
RUN chmod 700 /home/oacis/.ssh

#Add config files for supervised to start up daemons
RUN if [ ! -d /var/run/sshd ]; then mkdir /var/run/sshd; fi; echo "[program:sshd]" > /etc/supervisor/conf.d/sshd.conf && echo "command=/usr/sbin/sshd -D" >> /etc/supervisor/conf.d/sshd.conf && echo "autostart=true" >> /etc/supervisor/conf.d/sshd.conf && echo "autorestart=true" >> /etc/supervisor/conf.d/sshd.conf
RUN echo "[program:mongod]" > /etc/supervisor/conf.d/mongod.conf && echo "command=/usr/bin/mongod --fork --logpath /var/log/mongodb.log" >> /etc/supervisor/conf.d/mongod.conf && echo "autostart=true" >> /etc/supervisor/conf.d/mongod.conf && echo "autorestart=true" >> /etc/supervisor/conf.d/mongod.conf

#Start OACIS
#When you logout from bash (type exit), OACIS daemons are going to stop automatically
ENTRYPOINT /usr/bin/supervisord; su - -c "cd ~/oacis; bundle exec rake daemon:start; if [ ! -f ~/.ssh/id_rsa ]; then echo -e \"\\n\" | ssh-keygen -N \"\" -f $HOME/.ssh/id_rsa; cat $HOME/.ssh/id_rsa.pub > $HOME/.ssh/authorized_keys; chmod 600 $HOME/.ssh/authorized_keys; fi" oacis; su - oacis; su - -c "cd ~/oacis; bundle exec rake daemon:stop" oacis
