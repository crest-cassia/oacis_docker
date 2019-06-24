######################################
# OACIS Dockerfile from Ubuntu Image #
######################################
FROM oacis/oacis:latest
MAINTAINER "OACIS developers" <oacis-dev@googlegroups.com>

USER oacis
WORKDIR /home/oacis
ENV HOME /home/oacis
RUN wget -O conda.sh https://repo.continuum.io/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh \
    && bash conda.sh -b \
    && ~/miniconda3/bin/conda clean -tipsy \
    && rm conda.sh \
    && echo 'export LANG=C.UTF-8' >> ~/.bash_profile \
    && echo '. /home/oacis/miniconda3/etc/profile.d/conda.sh' >> ~/.bash_profile \
    && echo "conda activate base" >> ~/.bash_profile \
    && . ~/.bash_profile \
    && conda install -y \
        python=3.5 \
        numpy \
        pandas \
        matplotlib \
        jupyter \
    && conda clean -tipsy \
    && pip install msgpack-python==0.4.8 msgpack-rpc-python==0.4.1 fibers \
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

