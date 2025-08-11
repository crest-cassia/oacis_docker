#!/bin/bash -eu

cd $(dirname $0)

# parse option
usage() {
    echo "Usage: ./oacis_restore_db.sh [OPTIONS]"
    echo "  Restore mongodb from the backup file 'Result/db_dump'"
    echo
    echo "Options:"
    echo "  -h, --help : show this message"
    echo
    exit 1
}

while (( $# > 0 ))
do
  case $1 in
    -h | --help)
      usage
      exit 1
      ;;
    *)
      echo "[Error] invalid argument"
      usage
      exit 1
      ;;
  esac
done


if [ ! -e "Result/db_dump" ]; then
  echo "===== db_dump file 'Result/db_dump' is not found ====="
  exit 1
fi

set -x
script_dir=$(cd $(dirname $0); pwd)
RESULT_DIR="$script_dir/Result"
DUMP_FILE="$RESULT_DIR/db_dump"
DUMP_TMP_FILE="$RESULT_DIR/db_dump_backup_$(date '+%Y%m%d_%H:%M:%S')"

docker compose exec mongo mongodump --archive --db=oacis_development > "$DUMP_TMP_FILE"

docker compose exec -T mongo mongorestore --archive --db=oacis_development --drop < "$DUMP_FILE"

set +x
echo "DB was successfully restored from \"$DUMP_FILE\"" >&2
echo "Backup saved to \"$DUMP_TMP_FILE\"" >&2