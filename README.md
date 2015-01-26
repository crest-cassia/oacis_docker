# oacis_docker

[![release](https://img.shields.io/github/release/crest-cassia/oacis.svg)](https://github.com/crest-cassia/oacis/releases/latest)
[![docker image](http://img.shields.io/badge/docker_image-ready-brightgreen.svg)](https://registry.hub.docker.com/u/takeshiuchitane/oacis/)

You can run [OAICS](https://github.com/crest-cassia/oacis) anywhere.

## Getting Started

1. Setup docker environment (if you have not installed docker yet.)

  - See [Docker home page](https://www.docker.com/).

2. Start a new OACIS container by running the start script.

    ```sh:run_oacis_docker.sh
./bin/run_oacis_docker.sh {YOUR PROJECT NAME} {PORT}
    ```

3. Stop the container

  - Run `exit` in the container.
  - When you exit the container, oacis process is going to be stoped automatically.

4. Restart a container for an existing project

  - Run the start script with an existing project name to restart your project.

## More infomation

See [wiki](https://github.com/crest-cassia/oacis_docker/wiki) for usage and tips.

## License

  - Files in this repositories are a part of [OACIS](https://github.com/crest-cassia/oacis).
  - OACIS are published under the term of the MIT License (MIT).
  - Copyright (c) 2014,2015 RIKEN, AICS
