###################################
# OACIS Dockfile for Ubuntu Image #
###################################
FROM ubuntu:14.04
MAINTAINER "OACIS developers" <oacis-dev@googlegroups.com>

#Setup packages for oacis and its analyzers
RUN apt-get update && apt-get install -y openssh-server git build-essential curl gawk libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev supervisor; apt-get clean

#Add config files for supervised to start up daemons
RUN if [ ! -d /var/run/sshd ]; then mkdir /var/run/sshd; fi
ADD sshd.conf /etc/supervisor/conf.d/

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
RUN git checkout master; git pull origin master; git pull origin master --tags; /bin/bash -l -c "bundle install --path=vendor/bundle"
RUN /bin/bash -l -c "bundle install --path=vendor/bundle"

#install xsub
RUN git clone https://github.com/crest-cassia/xsub.git /home/oacis/xsub; bash -c 'echo -e "\nexport PATH=\$PATH:/home/oacis/xsub/bin\nexport XSUB_TYPE=\"none\"" >> /home/oacis/.bashrc'; bash -c 'echo -e "\nexport PATH=\$PATH:/home/oacis/xsub/bin\nexport XSUB_TYPE=\"none\"" >> /home/oacis/.bash_profile'

#Start OACIS
USER root
ENV HOME /home/oacis
WORKDIR /home/oacis
#Expose ports
EXPOSE 3000
#Create data volumes for OAICS
VOLUME ["/home/oacis/oacis/public/Result_development"]
VOLUME ["/home/oacis/work"]
VOLUME ["/home/oacis/.ssh"]

#Start mongodb daemon and OACIS daemons.
#When you stop the container (run exit), OACIS daemons and mongodb process are going to stop automatically
ADD start_ssh_and_run_oacis.sh /home/oacis/
CMD ["./start_ssh_and_run_oacis.sh"]
