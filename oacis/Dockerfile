######################################
# OACIS Dockerfile from Ubuntu Image #
######################################
FROM buildpack-deps:stretch
LABEL maintainer="OACIS developers <oacis-dev@googlegroups.com>"

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 \
    && echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list \
    && apt-get update \
    && apt-get install -y \
        openssh-server \
        mongodb-org=4.0.10 mongodb-org-server=4.0.10 mongodb-org-shell=4.0.10 mongodb-org-mongos=4.0.10 mongodb-org-tools=4.0.10 \
        redis-server \
        rsync \
        supervisor \
        vim \
        less \
        bash-completion \
    && apt-get clean \
    && mkdir -p /var/run/sshd \
    && cp /etc/redis/redis.conf /etc/redis/redis.conf.org \
    && sed -e 's/daemonize yes/daemonize no/' /etc/redis/redis.conf.org > /etc/redis/redis.conf

# Install Ruby, OACIS & xsub
RUN useradd -ms /bin/bash oacis
USER oacis
WORKDIR /home/oacis
ARG OACIS_VERSION
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv \
    && echo 'export LANG=C.UTF-8' >> ~/.bash_profile \
    && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile \
    && . ~/.bash_profile \
    && echo 'eval "$(rbenv init -)"' >> ~/.bash_profile \
    && . ~/.bash_profile \
    && mkdir -p "$(rbenv root)"/plugins \
    && git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build \
    && rbenv install 2.7.2 \
    && rbenv global 2.7.2 \
    && gem update bundler \
    && rbenv rehash \
    && git clone --recursive -b ${OACIS_VERSION:-master} https://github.com/crest-cassia/oacis.git \
    && cd oacis \
    && bundle install \
    && echo "---\nbinding_ip: '0.0.0.0'" > config/user_config.yml \
    && git clone https://github.com/crest-cassia/xsub.git /home/oacis/xsub \
    && echo "export PATH=\$PATH:/home/oacis/xsub/bin" >> /home/oacis/.bash_profile \
    && echo "export XSUB_TYPE=\"none\"" >> /home/oacis/.bash_profile \
    && echo "export OACIS_ROOT=/home/oacis/oacis" >> /home/oacis/.bash_profile \
    && echo 'export USER=$(whoami)' >> /home/oacis/.bash_profile \
    && mkdir -p /home/oacis/oacis/public/Result_development \
    && mkdir -p /home/oacis/.ssh

#put oacis_start.sh
USER root
COPY sshd.conf /etc/supervisor/conf.d/
COPY mongod.conf /etc/supervisor/conf.d/
COPY redis.conf /etc/supervisor/conf.d/
COPY oacis_start.sh /home/oacis/
COPY ssh_config /etc/ssh/ssh_config_template
RUN chown oacis:oacis /home/oacis/oacis_start.sh \
    && cat /etc/ssh/ssh_config_template >> /etc/ssh/ssh_config

# scritp to setup a sample simulator used in tutorial
COPY setup_ns_model.sh /home/oacis/
RUN chown oacis:oacis /home/oacis/setup_ns_model.sh

#Start OACIS
WORKDIR /home/oacis
ENV HOME /home/oacis
ENV OACIS_ROOT /home/oacis/oacis
#Expose ports
EXPOSE 3000
#Create data volumes for OAICS
VOLUME ["/data/db"]
VOLUME ["/home/oacis/oacis/public/Result_development"]

#Start mongodb daemon and OACIS daemons.
#When you stop the container (run exit), OACIS daemons and mongodb process are going to stop automatically
CMD ["./oacis_start.sh"]
