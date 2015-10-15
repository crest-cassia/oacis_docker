# oacis_docker

[![release](https://img.shields.io/github/release/crest-cassia/oacis.svg)](https://github.com/crest-cassia/oacis/releases/latest)
[![docker image](http://img.shields.io/badge/docker_image-ready-brightgreen.svg)](https://registry.hub.docker.com/u/takeshiuchitane/oacis/)

You can run [OAICS](https://github.com/crest-cassia/oacis) anywhere.

## Quick Start

1. Setup docker environment

    - See [Docker home page](https://www.docker.com/).
    - If you are Mac or WIndows user, install [Docker Toolbox](https://www.docker.com/toolbox).

2. Get and run a start script.

    ```sh
    git clone https://github.com/crest-cassia/oacis_docker.git
    cd /path/to/workdir
    /path/to/oacis_docker/bin/start.sh {YOUR_PROJECT_NAME} [PORT]
    ```

    - The default port is 3000.
    - (for Mac or Windows users) Run the above command in *Docker Quickstart Terminal*.
    - Directory {YOUR_PROJECT_NAME} is created and your simuluation results are stored in this directory.

3. Access OACIS web interface

    - You can access OACIS web interface via a web browser.(`http://localhost:{PORT}`)
    - (Mac or Windows) Access `192.168.99.100` instead of `localhost`.
        - ![docket_tool_ip](https://github.com/crest-cassia/oacis_docker/wiki/images/docker_tool_ip.png)

4. To stop the container, run the following command.

    ```sh
    /path/to/oacis_docker/bin/stop.sh {YOUR_PROJECT_NAME}
    ```

5. To restart a stopped container, run the following command.

    ```sh
    cd /path/to/workdir
    /path/to/oacis_docker/bin/restart.sh {YOUR_PROJECT_NAME}
    ```

    - To remove the container and the data, stop the container and then run

        ```sh
        cd /path/to/workdir
        /path/to/oacis_docker/bin/remove.sh {YOUR_PROJECT_NAME}
        rm -r {YOUR_PROJECT_NAME}
        ```

## Backup and Restore

To make a backup, run the following command to dump DB data in the container.
Data will be exported to {YOUR_PROJECT_NAME} directory.

```sh
cd /path/to/workdir
/path/to/oacis_docker/bin/dump.sh PROJECT_NAME
```

Then, please make a backup of the directory *PROJECT_NAME/*.
Containers must be running when you make a backup.

To restore data from a backup directory named {YOUR_PROJECT_NAME}, run the following command to import the data to DB.

```sh
/path/to/oacis_docker/bin/restore.sh {YOUR_PROJECT_NAME}
```

## Logging in the container

By logging in the container, you can update the configuration of the container.
For instance, you can install additional packages, set up ssh-agent, and see the logs.

To login the container as a normal user, run

```sh
/path/to/oacis_docker/bin/shell_exec.sh PROJECT_NAME
```

To login as the root user, run

```sh
/path/to/oacis_docker/bin/shell_exec_root.sh PROJECT_NAME
```

## More infomation

See [wiki](https://github.com/crest-cassia/oacis_docker/wiki).

## License

  - [oacis_docker](https://github.com/crest-cassia/oacis_docker) is a part of [OACIS](https://github.com/crest-cassia/oacis).
  - OACIS and oacis_docker are published under the term of the MIT License (MIT).
  - Copyright (c) 2014,2015 RIKEN, AICS

