#!/bin/bash -eu

cd $(dirname $0)

# parse option
usage() {
    echo "Usage: ./oacis_mcp.sh"
    echo "  Launch the OACIS MCP server (stdio) in the running container."
    echo "  Register it to an AI agent, e.g.:"
    echo "    claude mcp add oacis -- /path/to/oacis_docker/oacis_mcp.sh"
    echo
    echo "Options:"
    echo "  -h, --help: show this message"
    echo
    exit 1
}

while (( $# > 0 ))
do
  case $1 in
    -h | --help)
      usage
      ;;
    *)
      echo "[Error] invalid argument"
      usage
      ;;
  esac
done

# -T: no TTY. stdout/stdin are used for the MCP stdio protocol.
exec docker compose exec -T -u oacis oacis /home/oacis/oacis/bin/oacis_mcp
