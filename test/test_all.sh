#!/bin/bash

for script in `ls ./test/run/*.sh`
do
  echo "$script"
  $script
done

for script in `ls ./test/dump_restore/*.sh`
do
  echo "$script"
  $script
done

