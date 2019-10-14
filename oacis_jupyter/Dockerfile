######################################
# OACIS Dockerfile from Ubuntu Image #
######################################
ARG OACIS_VERSION
FROM oacis/oacis:${OACIS_VERSION:-latest}
MAINTAINER "OACIS developers" <oacis-dev@googlegroups.com>

USER oacis
WORKDIR /home/oacis
ENV HOME /home/oacis
COPY Pipfile /home/oacis/Pipfile
COPY Pipfile.lock /home/oacis/Pipfile.lock
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv \
    && echo 'export LC_ALL=C.UTF-8' >> ~/.bash_profile \
    && echo 'export LANG=C.UTF-8' >> ~/.bash_profile \
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile \
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile \
    && printf 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi\n' >> ~/.bash_profile
RUN . ~/.bash_profile \
    && pyenv install 3.6.9 \
    && pyenv global 3.6.9
RUN . ~/.bash_profile \
    && pip install --upgrade pip \
    && pip install pipenv \
    && pyenv rehash \
    && pipenv --clear install \
    && mkdir -p ~/.jupyter \
    && echo 'c.NotebookApp.token = ""' > ~/.jupyter/jupyter_notebook_config.py \
    && echo 'c.NotebookApp.password = ""' >> ~/.jupyter/jupyter_notebook_config.py \
    && echo 'c.NotebookApp.ip = "0.0.0.0"' >> ~/.jupyter/jupyter_notebook_config.py \
    && echo 'c.NotebookApp.open_browser = False' >> ~/.jupyter/jupyter_notebook_config.py
ENV PYTHONPATH=$OACIS_ROOT:$PYTHONPATH

USER root
COPY jupyter.conf /etc/supervisor/conf.d/
EXPOSE 8888
CMD ["./oacis_start.sh"]

