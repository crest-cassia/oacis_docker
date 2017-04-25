# OACIS + plham with x10 environment

## What it Gives You

In addition to `oacis/oacis_jupyter` image, the following applications and libraries are installed.

- default-jdk (for x10)
- x10-2.5.4 (for plham)
- nkf (for text code modification)

## Basic Usage

The following command starts a container with OACIS and the Jupyter Notebook server listening for HTTP connections on port 3000 and 8888, respectively.

```
docker run --name my_oacis -p 127.0.0.1:3000:3000 -p 127.0.0.1:8888:8888 -dt oacis/oacis_jupyter_plham
```

If you are using Docker Toolbox, run the following.

```
docker run --name my_oacis -p 3000:3000 -p 8888:8888 -dt oacis/oacis_jupyter_plham
```

After running a container, enter the container and run setup script for plham.
```
docker exec -it -u oacis my_oaics bash #login and run commands
#or
docker exec -it -u oacis my_oaics bash {command} #run a command
```

Commands related with plham.
```
#download and install plham
~/setup_plham.sh
#build an example CI2002
~/plham_tutorial/CI2002/build_binary.sh
#install CI2002 to OACIS
~/plham_tutorial/CI2002/install_to_OACIS.sh
#install seminer simulator to OACIS
~/plahm_tutorial/seminer/install_to_OACIS.sh
```

Basically, the usage is same as the [base image](../oacis) image.
In this image, however, a jupyter server is launched at 8888 port in addition to OACIS.
Access [http://localhost:8888](http://localhost:8888) via your web browser. If you are using Docker toolbox, access [http://192.168.99.100:8888](http://192.168.99.100:8888) instead of localhost.

