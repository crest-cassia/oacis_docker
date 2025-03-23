#!/bin/bash

script_path=$(dirname $0)

for script in `ls $script_path/run/*.sh`
do
  echo "$script"
  $script
  rc=$?
  if [ $rc -ne 0 ]
  then
    exit $rc
  fi
done
