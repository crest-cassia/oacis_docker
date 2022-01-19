# Dockerfile for OACIS

[![GitHub version](https://badge.fury.io/gh/crest-cassia%2Foacis_docker.svg)](https://badge.fury.io/gh/crest-cassia%2Foacis_docker)
[![docker image](http://img.shields.io/badge/docker_image-ready-brightgreen.svg)](https://registry.hub.docker.com/r/oacis/oacis/)
[![Build Status](https://travis-ci.org/crest-cassia/oacis_docker.svg?branch=develop)](https://travis-ci.org/crest-cassia/oacis_docker)

Ready-to-run [OACIS](https://github.com/crest-cassia/oacis) application in Docker.

## Quick Start

If you're familiar with Docker, have it configured, and know exactly what you'd like to run, this one-liner should work in most cases:

```
docker run --name my_oacis -p 127.0.0.1:3000:3000 -dt oacis/oacis
```

Or if you are using OACIS with Jupyter:

```
docker run --name my_oacis -p 127.0.0.1:3000:3000 -p 127.0.0.1:8888:8888 -dt oacis/oacis_jupyter
```

When using Docker toolbox, the command to launch the container is slightly different:

```
docker run --name my_oacis -p 3000:3000 -dt oacis/oacis
```

or

```
docker run --name my_oacis -p 3000:3000 -p 8888:8888 -dt oacis/oacis_jupyter
```


## Getting Started

If this is your first time using Docker or OACIS, do the following to get started.

1. [Install Docker](https://docs.docker.com/installation/) on your host of choice.
2. Open the README in one of the folders in this git repository.
3. Follow the README.

## Available Projects

- [oacis](oacis)
    - A base image, which consists of OACIS and its prerequisites.
- [oacis\_jupyter](oacis_jupyter)
    - On top of the "base" image, Python and Jupyter environments are installed.

## Registering a sample simulator

The following command registers a sample simulator "Nagel_Schreckenberg" to OACIS.
This is useful for you to quickly try the [tutorial of OACIS](http://crest-cassia.github.io/oacis/en/tutorial.html).
After this command, Step1 and Step2 of the tutorial are already finished. You can start from Step3.

```
docker exec -t -u oacis my_oacis bash -l /home/oacis/setup_ns_model.sh
```

The source code of the sample simulator can be found at [yohm/nagel_schreckenberg_model](https://github.com/yohm/nagel_schreckenberg_model).

## Registering a remote host  

To register a new remote host, you need to enable your container to access to your remote host (remote computer).  
First, log in to the container you have just created.    

```sh
docker exec -it -u oacis my_oacis bash -l
```

Then, edit your container's `config`. Open it like `vim ~/.ssh/config`.  
Once you open `config`, you should see the default setting. Change the setting according to your remote host's setting. For example,  
```sh
Host my_remote_host # this field is used when registering your remote host later 
 HostName 192.168.111.133 # address of your remote host
 Port 22
 User bob # your username of your remote computer's home directory.  
 IdentityFile ~/.ssh/id_rsa
```

Next, register your container's ssh public key into your remote host.  
```sh
cat .ssh/id_rsa.pub
```
Copy its output and paste it into your remote host's `~/.ssh/authorized_keys`.  


Finally, access [http://localhost:3000/hosts/new](http://localhost:3000/hosts/new) via your web browser.  
In the `Name` field in the GUI, fill in the value in the `Host` field you have entered in `~/.ssh/config` on your container. In this example, put "my_remote_host" in the `Name` field.  
You should now be able to add your remote host.  


## (For developers) Creating images for a specific OACIS version

To create images for a specific OACIS version and push them to dockerhub, edit `OACIS_VERSION` in "version_tagging.sh" and run it as following.

```
git pull
# edit "version_tagging.sh"
git commit version_tagging.sh
./version_tagging.sh
git tag -a ${OACIS_VERSION} -m "version ${OACIS_VERSION}"
git push
git tag --push
```

## License

- [oacis_docker](https://github.com/crest-cassia/oacis_docker) is a part of [OACIS](https://github.com/crest-cassia/oacis).
- OACIS and oacis_docker are published under the term of the MIT License (MIT).
- Copyright (c) 2014-2017 RIKEN, AICS

