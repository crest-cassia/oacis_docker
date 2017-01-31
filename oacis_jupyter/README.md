# OACIS + Jupyter Notebook Image

## What it Gives You

In addition to `oacis/oacis` image, the following applications and libraries are installed.

- Conda Python 3.x environments.
    - Jupyter Notebook
    - numpy, matplotlib, pandas

## Basic Usage

The following command starts a container with OACIS and the Jupyter Notebook server listening for HTTP connections on port 3000 and 8888, respectively.

```
docker run --name my_oacis -p 127.0.0.1:3000:3000 -p 127.0.0.1:8888:8888 -dt oacis/oacis_jupyter
```

If you are using Docker Toolbox, run the following.

```
docker run --name my_oacis -p 3000:3000 -p 8888:8888 -dt oacis/oacis_jupyter
```

Basically, the usage is same as the [base image](../oacis) image.
In this image, however, a jupyter server is launched at 8888 port in addition to OACIS.
Access [http://localhost:8888](http://localhost:8888) via your web browser. If you are using Docker toolbox, access [http://192.168.99.100:8888](http://192.168.99.100:8888) instead of localhost.

