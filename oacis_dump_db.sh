#!/bin/bash -eu

cd $(dirname $0)

# parse option
usage() {
    echo "Usage: ./oacis_dump_db.sh [OPTIONS]"
    echo "  Make a buckup file of mongodb used in OACIS container at 'Result/db_dump'"
    echo "  Once you ran this command, a complete backup of OACIS is stored under the 'Result/' directory."
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

set -eux
script_dir=$(cd $(dirname $0); pwd)
RESULT_DIR="$script_dir/Result"
DUMP_FILE="db_dump_$(date '+%Y%m%d_%H:%M:%S')"
DUMP_FILE_LINK="db_dump"

# mongoコンテナ内でmongodumpを実行し、結果をホストにコピー
docker compose exec mongo mongodump --archive --db=oacis_development > "$RESULT_DIR/$DUMP_FILE"
cd "$RESULT_DIR"
ln -fs "$DUMP_FILE" "$DUMP_FILE_LINK"

set +x
echo "File \"$RESULT_DIR/$DUMP_FILE\" was successfully written"