# oacis_docker

[![GitHub version](https://badge.fury.io/gh/crest-cassia%2Foacis_docker.svg)](https://badge.fury.io/gh/crest-cassia%2Foacis_docker)
[![docker image](http://img.shields.io/badge/docker_image-ready-brightgreen.svg)](https://registry.hub.docker.com/u/takeshiuchitane/oacis/)
[![Build Status](https://travis-ci.org/crest-cassia/oacis_docker.svg?branch=develop)](https://travis-ci.org/crest-cassia/oacis_docker)

You can run [OAICS](https://github.com/crest-cassia/oacis) anywhere.

## Quick Start

1. Setup docker engine (version 1.8 or later is required.)

    - See [Docker home page](https://www.docker.com/).
    - If you are Mac or Windows user, install [Docker Toolbox](https://www.docker.com/toolbox).

2. Start an oacis instance
    ```sh
    docker run --name oacis -p 3000:3000 -dt oacis/oacis
    docker logs -f oacis # wait for boot
    ```
    - OACIS is ready when you get the following logs.
        ```
        Progress: |====================================================================|
        bundle exec rails s -d -b 0.0.0.0
        => Booting Thin
        => Rails 4.2.0 application starting in production on http://0.0.0.0:3000
        => Run `rails server -h` for more startup options
        ServiceWorker started.
        JobSubmitterWorker started.
        JobObserverWorker started.
        + echo booted
        booted
        + child=807
        + wait 807
        + tail -f /dev/null
        ```
    - The default port is 3000. (You can choose another port like `-p 3001:3000`.)
    - (for Mac or Windows users) Run the above command in *Docker Quickstart Terminal*.

3. Access OACIS web interface

    - You can access OACIS web interface via a web browser.(`http://localhost:3000`)
    - (Mac or Windows) Access `192.168.99.100` instead of `localhost`.
        - ![docket_tool_ip](https://github.com/crest-cassia/oacis_docker/wiki/images/docker_tool_ip.png)


## Stop and Restart

Find a running `oacis` container.
```sh
docker ps
#CONTAINER ID        IMAGE                     COMMAND                        CREATED         STATUS        PORTS                        NAMES
#3edbc17ee5e4        oacis/oacis:latest        "./oacis_docker_cmd/o"         1 days ago      Up 23 hours   0.0.0.0:3000->3000/tcp       oacis
```

Stop the container.
```sh
docker stop oacis
```

Find the stoped `oacis` container.
```sh
docker ps -a
#CONTAINER ID        IMAGE                     COMMAND                        CREATED         STATUS        PORTS                        NAMES
#3edbc17ee5e4        oacis/oacis:latest        "./oacis_docker_cmd/o"         1 days ago      Up 23 hours   0.0.0.0:3000->3000/tcp       oacis
```

Restart the container.
```sh
docker start oacis
docker logs -f oacis
```

Revome the container.
```sh
docker stop oacis
docker rm -v oacis
```

## Backup and Restore

To make a backup, run the following command to dump DB data.
Containers must be running when you make a backup.
Data will be exported to `/home/oacis/oacis/public/Result_development/db` directory in the container.

```sh
docker exec -it oacis bash -c "cd /home/oacis/oacis/public/Result_development; if [ ! -d db ]; then mkdir db; fi; cd db; mongodump --db oacis_development; mv dump dump-`date +%Y%m%d-%H%M`; chown -R oacis:oacis /home/oacis/oacis/public/Result_development/db"
```

Then, please make a backup of the directory *Result_development*.
```sh
docker cp oacis:/home/oacis/oacis/public/Result_development .
```


To restore data, run the following command to copy *Result_development* and restore db data from Result_development/db/dump.

```sh
docker create -t --name another_oacis -p 3001:3000 oacis/oacis
docker cp Result_development another_oacis:/home/oacis/oacis/public/
docker start another_oacis
sleep 20
docker exec -it another_oacis bash -c "cd /home/oacis/oacis/public/Result_development/db/\`cd /home/oacis/oacis/public/Result_development/db; ls | grep dump | sort | tail -n 1\`/oacis_development; mongorestore --db oacis_development ."
```

## Logging in the container

By logging in the container, you can update the configuration of the container.
For instance, you can install additional packages, set up ssh-agent, and see the logs.

To login the container as a normal user, run

```sh
docker exec -it oacis bash -c 'su - oacis; cd /home/oacis/oacis; exec "bash && exit"'
```

To login as the root user, run

```sh
docker exec -it oacis bash
```

## Firewall

Linux users must set up firewall for oacis_docker, otherwise anyone can access your oacis web-browser interface.
`iptables` is an application program for setting up firewall and docker-engine makes iptables configulations.
Run the following command as root on host machine to overwrite the configulations.

```sh
iptables -I FORWARD -i eth+ -o docker0 -p tcp -m tcp --dport 3000 -j DROP
```

If you are also using wifi, you need to run the following command additionally.

```sh
iptables -I FORWARD -i wlan+ -o docker0 -p tcp -m tcp --dport 3000 -j DROP
```

Note: `iptables` configurations are deleted when host OS reboots.

Note: If you would like to allow others to access oacis, run the following command.

```sh
iptables -I FORWARD -i eth+ -o docker0 -d $(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' oacis) -p tcp -m tcp --dport 3000 -j ACCEPT
```

## More infomation

See [wiki](https://github.com/crest-cassia/oacis_docker/wiki).

## License

  - [oacis_docker](https://github.com/crest-cassia/oacis_docker) is a part of [OACIS](https://github.com/crest-cassia/oacis).
  - OACIS and oacis_docker are published under the term of the MIT License (MIT).
  - Copyright (c) 2014,2015,2016 RIKEN, AICS

