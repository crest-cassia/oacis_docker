######################################
# OACIS Dockerfile from Ubuntu Image #
######################################
FROM ruby:2.3.3
MAINTAINER "OACIS developers" <oacis-dev@googlegroups.com>

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 \
    && echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.2 main" > /etc/apt/sources.list.d/mongodb-org-3.2.list \
    && apt-get update \
    && apt-get install -y \
        vim \
        bash-completion \
        openssh-server \
        mongodb-org-server \
        mongodb-org-shell \
        mongodb-org-tools \
        supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/sshd

#Install OACIS and xsub
RUN useradd -ms /bin/bash oacis
USER oacis
WORKDIR /home/oacis
RUN git clone -b master --recursive https://github.com/crest-cassia/oacis.git \
    && cd oacis \
    && bundle install --path=vendor/bundle \
    && git clone https://github.com/crest-cassia/xsub.git /home/oacis/xsub \
    && echo "export PATH=\$PATH:/home/oacis/xsub/bin; export XSUB_TYPE=\"none\"" >> /home/oacis/.bash_profile

#put oacis_start.sh
USER root
COPY sshd.conf /etc/supervisor/conf.d/
COPY mongod.conf /etc/supervisor/conf.d/
COPY oacis_start.sh /home/oacis/
RUN chown oacis:oacis /home/oacis/oacis_start.sh

#Start OACIS
WORKDIR /home/oacis
ENV HOME /home/oacis
#Expose ports
EXPOSE 3000
#Create data volumes for OAICS
VOLUME ["/data/db"]
VOLUME ["/home/oacis/oacis/public/Result_development"]

#Start mongodb daemon and OACIS daemons.
#When you stop the container (run exit), OACIS daemons and mongodb process are going to stop automatically
CMD ["./oacis_start.sh"]
