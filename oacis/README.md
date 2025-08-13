# OACIS Docker Image

## What it Gives You

- OACIS Ruby application with prerequisites:
    - Ruby 2.7.8
    - OACIS simulation management platform
    - OpenSSH server for remote connections
    - xsub job scheduler
    - Essential system packages (git, build tools, etc.)
- Unprivileged `oacis` user with OACIS installed at `~/oacis`
- SSH configuration for remote host connections
- Sample simulator setup script (`setup_ns_model.sh`)

**Note**: This image does NOT include MongoDB or Redis databases. These are provided as separate services via Docker Compose.

## Usage

**This image is designed to be used with the [oacis_docker](https://github.com/crest-cassia/oacis_docker) repository, which provides Docker Compose configuration with MongoDB and Redis services.**

### Quick Start

Instead of running this image directly, use the oacis_docker repository:

```bash
# Clone the oacis_docker repository
git clone https://github.com/crest-cassia/oacis_docker.git
cd oacis_docker

# Start OACIS with all required services
./oacis_boot.sh
```

This will start:
- OACIS application (this image)
- MongoDB database
- Redis cache
- Proper networking and volume mounting

### Access OACIS

After running `./oacis_boot.sh`, wait for the "OACIS READY" message, then access:
- Web interface: [http://localhost:3000](http://localhost:3000)

### Container Management

Use the provided scripts in oacis_docker repository:

```bash
# Stop containers (preserves data)
./oacis_stop.sh

# Restart stopped containers
./oacis_start.sh

# Access container shell
./oacis_shell.sh

# Backup database
./oacis_dump_db.sh

# Restore database
./oacis_restore_db.sh

# Terminate containers (deletes data)
./oacis_terminate.sh
```

## Direct Docker Usage (Not Recommended)

If you need to run this image directly without Docker Compose, you must provide external MongoDB and Redis services and configure the appropriate environment variables (`OACIS_MONGODB_URL`, `OACIS_REDIS_URL`).

For complete setup and usage instructions, please refer to the [oacis_docker repository](https://github.com/crest-cassia/oacis_docker).
