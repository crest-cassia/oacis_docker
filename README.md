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
docker exec -t -u oacis my_oacis bash /home/oacis/setup_ns_model.sh
```

The source code of the sample simulator can be found at [yohm/nagel_schreckenberg_model](https://github.com/yohm/nagel_schreckenberg_model).

## License

- [oacis_docker](https://github.com/crest-cassia/oacis_docker) is a part of [OACIS](https://github.com/crest-cassia/oacis).
- OACIS and oacis_docker are published under the term of the MIT License (MIT).
- Copyright (c) 2014-2017 RIKEN, AICS

