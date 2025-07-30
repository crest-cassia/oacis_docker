######################################
# OACIS Dockerfile from Debian Image #
# Built for x86_64 platform          #
######################################
FROM ruby:2.7.8
LABEL maintainer="OACIS developers <oacis-dev@googlegroups.com>"

# Add MongoDB official repository (x86_64 only!)
# RUN apt-get update && apt-get install -y gnupg curl ca-certificates


# Install essential dependencies and services
RUN apt-get update \
    && apt-get install -y \
        openssh-server \
        rsync \
        supervisor \
        vim \
        less \
        bash-completion \
        git \
        build-essential \
        libssl-dev \
        libreadline-dev \
        zlib1g-dev \
        curl \
        ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/sshd

# Install Ruby, OACIS, and xsub
RUN useradd -ms /bin/bash oacis
USER oacis
WORKDIR /home/oacis
ARG OACIS_VERSION

RUN git clone --recursive -b ${OACIS_VERSION:-master} https://github.com/crest-cassia/oacis.git \
    && cd oacis \
    && unset BUNDLE_APP_CONFIG \
    && bundle install --path vendor/bundle \
    && echo "---\nbinding_ip: '0.0.0.0'" > config/user_config.yml \
    && git clone https://github.com/crest-cassia/xsub.git /home/oacis/xsub \
    && echo "export PATH=\$PATH:/home/oacis/xsub/bin" >> /home/oacis/.bash_profile \
    && echo "export XSUB_TYPE=\"none\"" >> /home/oacis/.bash_profile \
    && echo "export OACIS_ROOT=/home/oacis/oacis" >> /home/oacis/.bash_profile \
    && echo 'export USER=$(whoami)' >> /home/oacis/.bash_profile \
    && mkdir -p /home/oacis/oacis/public/Result_development \
    && mkdir -p /home/oacis/.ssh

# Switch back to root to configure supervisor and SSH
USER root
COPY sshd.conf /etc/supervisor/conf.d/
COPY oacis_start.sh /home/oacis/
COPY ssh_config /etc/ssh/ssh_config_template
RUN chown oacis:oacis /home/oacis/oacis_start.sh \
    && cat /etc/ssh/ssh_config_template >> /etc/ssh/ssh_config

# Add sample simulator script
COPY setup_ns_model.sh /home/oacis/
RUN chown oacis:oacis /home/oacis/setup_ns_model.sh

# Environment & ports
WORKDIR /home/oacis
ENV HOME=/home/oacis
ENV OACIS_ROOT=/home/oacis/oacis
EXPOSE 3000
VOLUME ["/data/db"]
VOLUME ["/home/oacis/oacis/public/Result_development"]

# Start command
CMD ["./oacis_start.sh"]
