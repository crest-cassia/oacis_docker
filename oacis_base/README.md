# OACIS base Image

## What it Gives You

- latest OACIS and its prerequisites
    - OACIS
    - Ruby
    - MongoDB
    - OpenSSH server
    - xsub
- SSH settings are configured such that an SSH connection to the container itself becomes possible.
- Unprivileged user `oacis` in group `oacis` with ownership over `home/oacis`.
    - OACIS is installed at `~/oacis` for `oacis` user.

## Basic Usage

The following command starts a container with OACIS listening for HTTP connections on port 3000. The port is exposed locally, i.e., it is inaccessible from other hosts.

```
docker run --name my_oacis -p 127.0.0.1:3000:3000 -dt oacis/oacis_base
```

A few tens of seconds are necessary to complete the booting of OACIS. To see if OACIS is ready to use, run the following command to see the standard output of the booting process.

```
docker logs -f my_oacis   # wait for boot. Exit by Ctrl + C
```

When you see the output like the following, OACIS is ready to use.

```
...
+ echo '==== OACIS READY ===='
==== OACIS READY ====
+ child=232
+ wait 232
+ tail -f /dev/null
```

Access [http://localhost:3000](http://localhost:3000) via your web browser. If you are using Docker toolbox, access `http://192.168.99.100:3000` instead of localhost. 

### Stopping and Restarting

Find a running container via `docker ps` command.

```sh
$ docker ps
CONTAINER ID     IMAGE               COMMAND              CREATED             STATUS          PORTS                      NAMES
e279dbdcc855     oacis/oacis_base    "./oacis_start.sh"   About an hour ago   Up 5 minutes    127.0.0.1:3002->3000/tcp   my_oacis
```

Stop the container by `docker stop` command. The `-t` option specifies seconds to wait for stop before killing it. Since OACIS requires some time to gracefully stop the daemon, we recommend to set it longer by the default value (10sec).

```sh
$ docker stop -t 60 my_oacis
```

You'll see the list of stopped container by `docker ps -a` command.

```sh
$ docker ps -a
CONTAINER ID     IMAGE                COMMAND             CREATED             STATUS                       PORTS        NAMES
e279dbdcc855     oacis/oacis_base     "./oacis_start.sh"  About an hour ago   Exited (137) 2 minutes ago                my_oacis
```

To restart the stopped container, use `docker start` command. Use `docker logs -f` as well to see if the booting has finished.

```sh
$ docker start my_oacis
$ docker logs -f my_oacis
```

To remove the stopped container, use `docker rm -v`. If you want to remove the image as well, run `docker rmi`.

```sh
$ docker rm -v my_oacis          # removing the container
$ docker rmi oacis/oacis_base    # removing the image of OACIS
```

## Mounting a directory

Simulation results are stored in "/home/oacis/oacis/public/Result_development" directory. You can mount a directory of the host machine to this directory.

```
docker run --name my_oacis -p 127.0.0.1:3000:3000 -v $(pwd):/home/oacis/oacis/public/Result_development -dt oacis/oacis_base
```

## Backup and Restore

To make a backup, run the following command to dump DB data.
Containers must be running when you make a backup.
Data will be exported to `/home/oacis/oacis/public/Result_development/dump` directory in the container.

```sh
$ docker exec -it oacis bash -c "cd /home/oacis/oacis/public/Result_development; mongodump --db oacis_development; chown -R oacis:oacis dump"
```

Then, please make a backup of the directory *Result_development*.

```sh
docker cp oacis:/home/oacis/oacis/public/Result_development .
```

To restore data, run the following command to copy *Result_development* and restore db data from `Result_development/dump`.

```sh
docker create -t --name another_oacis -p 3001:3000 oacis/oacis_base
docker cp Result_development another_oacis:/home/oacis/oacis/public/
docker start another_oacis
docker logs -f another_oacis   # wait until daemon process is ready
docker exec -it another_oacis bash -c "cd /home/oacis/oacis/public/Result_development/dump/oacis_development; mongorestore --db oacis_development ."
```

## Logging in the container

By logging in the container, you can update the configuration of the container.
For instance, you can install additional packages, set up ssh-agent, and see the logs.

To login the container as a normal user, run `docker exec` with `-u` option.

```sh
docker exec -it -u oacis my_oacis bash -l
```

To login as the root user, run

```sh
docker exec -it oacis bash -l
```

