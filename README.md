# oacis_docker

You can run [OAICS](https://github.com/crest-cassia/oacis) anywhere.

## Getting Started

1. Setup docker environment (if you have not installed docker yet.)

  - See [Docker home page](https://www.docker.com/).

2. Run start script like,

    ```sh:run-docker-oacis.sh
./run-docker-oacis.sh {YOUR PROJECT NAME} {PORT}
    ```

  - ex.

    ```sh:example
./run-docker-oacis test 3000
# Create project directory ./test, ./test/db, ./test/Result_development and ./test/.ssh
# You can access oacis via webbrowser like http://localhost:3000.
    ```

3. Stop and restart your project

  - When you exit form your project, oacis process will be going to stop automatically.
  - Just run `run-docker-oacis` to restart your project

## More infomation

See [wiki](https://github.com/crest-cassia/oacis_docker/wiki) for usage and tips.

## License

  - TBA
  - Copyright (c) 2014 RIKEN, AICS
