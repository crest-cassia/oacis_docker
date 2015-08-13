# oacis_docker

[![release](https://img.shields.io/github/release/crest-cassia/oacis.svg)](https://github.com/crest-cassia/oacis/releases/latest)
[![docker image](http://img.shields.io/badge/docker_image-ready-brightgreen.svg)](https://registry.hub.docker.com/u/takeshiuchitane/oacis/)

You can run [OAICS](https://github.com/crest-cassia/oacis) anywhere.

## Quick Start

1. Setup docker environment (if you have not installed docker yet.)

    - See [Docker home page](https://www.docker.com/).

2. Get and run scripts.

    ```sh
    git clone https://github.com/crest-cassia/oacis_docker.git
    cd /path/to/workdir
    /path/to/oacis_docker/bin/start.sh {YOUR_PROJECT_NAME} {PORT}
    ```
3. Access OACISS web interface

    - You can access OACIS web interface via a web browser.(`http://localhost:{PORT}`)
    - if you are Mac OS or Microsoft Windows users, access `192.168.59.103` instead of `localhost`.

4. Stop the container

  - Run `exit` command in the container.
  - When you exit the container, oacis process is going to be stoped automatically.

4. Restart a container for an existing project

  - Run the script again with an existing project name at the same workdir.

## More infomation

See [wiki](https://github.com/crest-cassia/oacis_docker/wiki).

## License

  - [oacis_docker](https://github.com/crest-cassia/oacis_docker) is a part of [OACIS](https://github.com/crest-cassia/oacis).
  - OACIS are published under the term of the MIT License (MIT).
  - Copyright (c) 2014,2015 RIKEN, AICS
