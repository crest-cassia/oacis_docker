# oacis_docker

[![release](https://img.shields.io/github/release/crest-cassia/oacis.svg)](https://github.com/crest-cassia/oacis/releases/latest)
[![docker image](http://img.shields.io/badge/docker_image-ready-brightgreen.svg)](https://registry.hub.docker.com/u/takeshiuchitane/oacis/)

You can run [OAICS](https://github.com/crest-cassia/oacis) anywhere.

## Quick Start

1. Setup docker environment (if you have not installed docker yet.)

    - See [Docker home page](https://www.docker.com/).
    - Use [Docker Toolbox](https://www.docker.com/toolbox) if you are using Windows or Mac.

2. Get and run a start script.

    ```sh
    git clone https://github.com/crest-cassia/oacis_docker.git
    cd /path/to/workdir
    /path/to/oacis_docker/bin/start.sh {YOUR_PROJECT_NAME} [PORT]
    ```

    - The default port is 3000.
    - (for Mac or Windows users) Run the above command in *Docker Quickstart Terminal*.
    - A terminal of the container machine is launched.

3. Access OACIS web interface

    - You can access OACIS web interface via a web browser.(`http://localhost:{PORT}`)
    - (Mac or Windows) Access `192.168.99.100` instead of `localhost`.
        - ![docket_tool_ip](https://github.com/crest-cassia/oacis_docker/wiki/images/docker_tool_ip.png)

4. Stop the container

  - Run `exit` command in the temrminal of the container.
  - After OACIS stops, the virtual machine also stops.

5. To restart a container of an existing project, run the script again.

  - Run the script again with an existing project name at the same workdir.

## Backup and Restore

To make a backup, run the following command to dump DB data.
Data will be exported to the directory *PROJECT_NAME/db/dump-YYYYMMDD-hhmm/oacis_development*.

```sh
./bin/backup_db.sh PROJECT_NAME
```

After running the above command, make a backup of the directory *PROJECT_NAME/*.

To restore data, prepare the project directory, and run the following command to import the data to DB.

```sh
./bin/restore_db.sh PROJECT_NAME path/to/dump/oacis_development
```

## More infomation

See [wiki](https://github.com/crest-cassia/oacis_docker/wiki).

## License

  - [oacis_docker](https://github.com/crest-cassia/oacis_docker) is a part of [OACIS](https://github.com/crest-cassia/oacis).
  - OACIS and oacis_docker are published under the term of the MIT License (MIT).
  - Copyright (c) 2014,2015 RIKEN, AICS

