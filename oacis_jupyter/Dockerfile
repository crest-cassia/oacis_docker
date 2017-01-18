######################################
# OACIS Dockerfile from Ubuntu Image #
######################################
FROM oacis_base:latest
MAINTAINER "OACIS developers" <oacis-dev@googlegroups.com>

USER oacis
WORKDIR /home/oacis
ENV HOME /home/oacis
RUN wget -O conda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash conda.sh -b \
    && rm conda.sh \
    && echo 'export PATH=/home/oacis/miniconda3/bin:$PATH' >> ~/.bash_profile \
    && . ~/.bash_profile \
    && conda install -y numpy matplotlib jupyter \
    && pip install msgpack-rpc-python \
    && mkdir -p ~/.jupyter \
    && echo 'c.NotebookApp.token = ""' > ~/.jupyter/jupyter_notebook_config.py \
    && echo 'c.NotebookApp.password = ""' >> ~/.jupyter/jupyter_notebook_config.py \
    && echo 'c.NotebookApp.ip = "0.0.0.0"' >> ~/.jupyter/jupyter_notebook_config.py \
    && echo 'c.NotebookApp.open_browser = False' >> ~/.jupyter/jupyter_notebook_config.py

USER root
COPY jupyter.conf /etc/supervisor/conf.d/
CMD ["./oacis_start.sh"]

