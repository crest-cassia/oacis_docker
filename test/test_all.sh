#!/bin/bash

for script in `ls ./test/run/*.sh`
do
  echo "$script"
  $script
  rc=$?
  if [ $rc -ne 0 ]
  then
    exit $rc
  fi
done

for script in `ls ./test/dump_restore/*.sh`
do
  echo "$script"
  $script
  rc=$?
  if [ $rc -ne 0 ]
  then
    exit $rc
  fi
done

