# oacis_docker

[![release](https://img.shields.io/github/release/crest-cassia/oacis.svg)](https://github.com/crest-cassia/oacis/releases/latest)
[![docker image](http://img.shields.io/badge/docker_image-ready-brightgreen.svg)](https://registry.hub.docker.com/u/takeshiuchitane/oacis/)

You can run [OAICS](https://github.com/crest-cassia/oacis) anywhere.

## Getting Started

1. Setup docker environment (if you have not installed docker yet.)

    - See [Docker home page](https://www.docker.com/).

2. Start a new OACIS container by running the script.

    ```sh:run_oacis_docker.sh
    ./bin/native-linux/run_oacis_docker.sh {YOUR_PROJECT_NAME} {PORT}
    ```

    - You can access OACIS web interface via a web browser.(`http://localhost:{PORT}`)
        - if you are boot2docker user, access `192.168.59.103` instead of `localhost`.

3. Stop the container

  - Run `exit` in the container.
  - When you exit the container, oacis process is going to be stoped automatically.

4. Restart a container for an existing project

  - Run the script again with an existing project name at the same directory.

## More infomation

See [wiki](https://github.com/crest-cassia/oacis_docker/wiki) for usage and tips.

## License

  - [oacis_docker](https://github.com/crest-cassia/oacis_docker) is a part of [OACIS](https://github.com/crest-cassia/oacis).
  - OACIS are published under the term of the MIT License (MIT).
  - Copyright (c) 2014,2015 RIKEN, AICS
