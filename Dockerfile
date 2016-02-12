######################################
# OACIS Dockerfile from Ubuntu Image #
######################################
FROM ubuntu:14.04
MAINTAINER "OACIS developers" <oacis-dev@googlegroups.com>

#Setup packages for oacis and its analyzers
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10; echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list
RUN apt-get update && apt-get install -y openssh-server git build-essential curl mongodb-org gawk libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev supervisor; apt-get clean

#Add config files for supervised to start up daemons
RUN if [ ! -d /var/run/sshd ]; then mkdir /var/run/sshd; fi
ADD sshd.conf /etc/supervisor/conf.d/
ADD mongod.conf /etc/supervisor/conf.d/

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
RUN git clone -b master https://github.com/crest-cassia/oacis.git
WORKDIR /home/oacis/oacis
RUN /bin/bash -l -c "bundle install --path=vendor/bundle"

#install xsub
RUN git clone https://github.com/crest-cassia/xsub.git /home/oacis/xsub; bash -c 'echo -e "\nexport PATH=\$PATH:/home/oacis/xsub/bin\nexport XSUB_TYPE=\"none\"" >> /home/oacis/.bashrc'; bash -c 'echo -e "\nexport PATH=\$PATH:/home/oacis/xsub/bin\nexport XSUB_TYPE=\"none\"" >> /home/oacis/.bash_profile'

#get oacis_start.sh
RUN git clone https://github.com/crest-cassia/oacis_docker_cmd.git /home/oacis/oacis_docker_cmd; cd /home/oacis/oacis_docker_cmd; git checkout -b save_localhost_if_no_host_exists origin/save_localhost_if_no_host_exists

#prepare tutorials
USER root
RUN mkdir /home/oacis/samples
ADD samples /home/oacis/samples/
RUN chown -R oacis:oacis /home/oacis/samples

#Start OACIS
ENV HOME /home/oacis
WORKDIR /home/oacis
#Expose ports
EXPOSE 3000
#Create data volumes for OAICS
VOLUME ["/data/db"]
VOLUME ["/home/oacis/oacis/public/Result_development"]

#Start mongodb daemon and OACIS daemons.
#When you stop the container (run exit), OACIS daemons and mongodb process are going to stop automatically
CMD ["./oacis_docker_cmd/oacis_start.sh"]
