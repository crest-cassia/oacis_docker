# Migrating oacis_docker from OACIS v3 to v4

This guide describes how to upgrade an existing oacis_docker installation from OACIS v3 to OACIS v4.

## What changed in OACIS v4 (relevant to Docker users)

- **Runtime**: OACIS now runs on Ruby 3.4 and Rails 7.2. This only affects the inside of the container — **your simulators are unaffected** (they can be written in any language, as before).
- **Python API removed**: `bin/oacis_python` and the Python version of `OacisWatcher` are no longer included. See [If you used the Python API](#if-you-used-the-python-api) below.
- **New: MCP server**: AI agents can create parameter sets, submit and monitor runs, and read results through `bin/oacis_mcp`. See the [MCP section of the README](README.md#mcp-server-for-ai-agents-oacis-v4).
- **Session secret**: v4 generates a per-installation session secret on first boot. You will be logged out of the web UI once after the upgrade (and whenever the container is recreated). This is harmless.
- **Unchanged**: the MongoDB and Redis service containers, the exposed port (3000), the `Result` directory layout, and all the management scripts (`oacis_boot.sh`, `oacis_dump_db.sh`, etc.) work the same way.

## 0. Back up your data first (required)

While your **old** setup is still running, using the scripts of your **old** oacis_docker checkout:

```shell
./oacis_dump_db.sh
rsync -avhz --progress Result /path/to/backup    # DB dump + all result files
```

`Result/db_dump` (the database dump) and the rest of the `Result` directory together contain everything needed to rebuild your OACIS installation.

## 1. Which setup are you upgrading from?

- **Case A — current multi-container setup**: `docker compose ps` in the oacis_docker directory shows three services (`oacis`, `mongo`, `redis`). Follow [2A](#2a-upgrade-from-the-multi-container-setup).
- **Case B — old single-container setup**: an older oacis_docker in which MongoDB ran *inside* the OACIS container (no separate `mongo` service). Follow [2B](#2b-upgrade-from-the-old-single-container-setup).

## 2A. Upgrade from the multi-container setup

```shell
./oacis_dump_db.sh        # backup (see step 0)
./oacis_terminate.sh      # removes the containers and the DB volume
git pull                  # update oacis_docker itself
docker pull oacis/oacis   # get the v4 image
./oacis_boot.sh
./oacis_restore_db.sh     # restore your data into the new setup
```

The `Result` directory is not touched by `oacis_terminate.sh`, so your simulation output files stay in place; `oacis_restore_db.sh` restores the database that references them.

**Shortcut (advanced)**: the MongoDB volume survives an image swap, so instead of terminate + restore you can run `docker compose down` (**without** `--volumes`), then `git pull`, `docker pull oacis/oacis`, and `./oacis_boot.sh`. The database schema is upgraded automatically at boot. Still take the dump in step 0 first.

## 2B. Upgrade from the old single-container setup

1. With the **old** setup still running, back up as in step 0 (`./oacis_dump_db.sh` of the old checkout, then copy `Result` somewhere safe).
2. Terminate the old setup with its own `./oacis_terminate.sh`.
3. Update oacis_docker (`git pull`, or a fresh `git clone`). Keep (or copy back) your `Result` directory at the same place, `oacis_docker/Result` — the bind-mount path is unchanged.
4. `./oacis_boot.sh` — this pulls the separate `mongo` and `redis` service images along with the OACIS v4 image.
5. `./oacis_restore_db.sh`

## If you used the Python API

The Python API (`bin/oacis_python`, the Python `OacisWatcher`, and the `rb_call` bridge) was removed in v4. Existing Python watcher scripts will not run. Options:

- Port your scripts to the **Ruby API** (`bin/oacis_ruby`, `OacisWatcher`): see the [API documentation](http://crest-cassia.github.io/oacis/en/api.html).
- For AI-agent-driven or external-tool workflows, use the new **MCP server**: see the [MCP documentation](http://crest-cassia.github.io/oacis/en/mcp.html) and `./oacis_mcp.sh` in this repository.

Note: simulators *written in* Python are unaffected — only the Python client API for controlling OACIS was removed.

## Remote computation hosts and xsub

Nothing changes on your remote hosts. Ruby 3 is required only by OACIS itself, which is bundled inside the container. `xsub` installed on remote hosts keeps working with the Ruby version already there (see the [xsub README](https://github.com/crest-cassia/xsub) for its own requirements).

## Minor notes

- You will be logged out of the web UI the first time the new container starts, and again whenever the container is recreated: v4 generates a per-installation session secret inside the container filesystem. To keep sessions across container re-creation, set the `SECRET_KEY_BASE` environment variable for the `oacis` service via a compose override file.
- The `Result` directory bind mount and its layout are unchanged; registered simulators, parameter sets, and result files are fully preserved through dump/restore.

## Troubleshooting

- Check the logs: `docker compose logs oacis` and `docker compose logs mongo`.
- `./oacis_restore_db.sh` fails: OACIS must be running — run `./oacis_boot.sh` first, wait for "OACIS READY", then retry.
- The web UI does not come up after upgrading: run `./oacis_shell.sh` and check `~/oacis/log/production.log`.
