###################################
# OACIS Dockfile for Ubuntu Image #
###################################

#FROM ubuntu:14.04
#libpam with --disable-audit option
FROM sequenceiq/pam:ubuntu-14.04
MAINTAINER "Takeshi Uchitane" <t.uchitane@gmail.com>

#Setup packages for oacis and its analyzers
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10; echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list; apt-get update && apt-get install -y openssh-server git build-essential curl mongodb-org gawk libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev supervisor; apt-get clean

#Create oacis user
RUN useradd -ms /bin/bash oacis
USER oacis
WORKDIR /home/oacis
ENV HOME /home/oacis

#Install rvm, ruby, bundler on oacia home directory
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3; \curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"; /bin/bash -l -c "rvm install 2.1"; echo "source $HOME/.rvm/scripts/rvm" >> $HOME/.bashrc; /bin/bash -l -c "gem install bundler"

#Install OACIS
WORKDIR /home/oacis
RUN git clone https://github.com/crest-cassia/oacis.git
WORKDIR /home/oacis/oacis
RUN git checkout master; git pull origin master; git pull origin master --tags; /bin/bash -l -c "bundle install --path=vendor/bundle"

USER root
ENV HOME /root
#Setting up packages for analyzers
#You can add any packages.
RUN echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list;gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9; gpg -a --export E084DAB9 | sudo apt-key add - ; apt-get update && apt-get install -y r-base gnuplot vim python-matplotlib; apt-get clean

#Expose ports
EXPOSE 3000

#Create data volumes for OAICS
VOLUME ["/home/oacis/db"]
VOLUME ["/home/oacis/oacis/public/Result_development"]
VOLUME ["/home/oacis/work"]
VOLUME ["/home/oacis/.ssh"]

#Add config files for supervised to start up daemons
RUN if [ ! -d /var/run/sshd ]; then mkdir /var/run/sshd; fi; echo "[program:sshd]" > /etc/supervisor/conf.d/sshd.conf && echo "command=/usr/sbin/sshd -D" >> /etc/supervisor/conf.d/sshd.conf && echo "autostart=true" >> /etc/supervisor/conf.d/sshd.conf && echo "autorestart=true" >> /etc/supervisor/conf.d/sshd.conf

#Start OACIS
ENV HOME /home/oacis
#Start mongodb daemon and OACIS daemons.
#When you stop the container (run exit), OACIS daemons and mongodb process are going to stop automatically
ENTRYPOINT chown -R oacis:oacis /home/oacis/db; chown -R oacis:oacis /home/oacis/oacis/public/Result_development; chown -R oacis:oacis /home/oacis/work; chown oacis:oacis /home/oacis/.ssh; chmod 700 /home/oacis/.ssh; if [ -d /home/oacis/db_backup ]; then chown -R oacis:oacis /home/oacis/db_backup; fi; /usr/bin/supervisord; su - -c "/usr/bin/mongod --fork --logpath /home/oacis/db/mongodb.log --dbpath /home/oacis/db; cd ~/oacis; bundle exec rake daemon:start; if [ ! -f ~/.ssh/id_rsa ]; then echo -e \"\\n\" | ssh-keygen -N \"\" -f $HOME/.ssh/id_rsa; cat $HOME/.ssh/id_rsa.pub > $HOME/.ssh/authorized_keys; chmod 600 $HOME/.ssh/authorized_keys; fi" oacis; su - oacis; su - -c "cd ~/oacis; bundle exec rake daemon:stop; pkill mongod" oacis; su - -c "if [ -d /home/oacis/db_backup ]; then rsync -a /home/oacis/db/* /home/oacis/db_backup/; fi" oacis; su - -c "if [ -d /home/oacis/.ssh_backup ]; then rsync -a /home/oacis/.ssh/* /home/oacis/.ssh_backup/; fi" oacis
