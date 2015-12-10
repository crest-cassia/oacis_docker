#!/bin/bash
TUTORIAL_NAME=$(basename ${0%.sh})
if [ ! -d /home/oacis/oacis/public/${TUTORIAL_NAME} ]
then
  #clean up old data on DB and file system
  mongo  oacis_development --eval 'db.dropDatabase();'
  rm -rf /home/oacis/oacis/public/Result_development/*
  #restore tutorial
  cd /home/oacis/oacis/public; tar jxf /home/oacis/samples/${TUTORIAL_NAME}.tar.bz2; mv ${TUTORIAL_NAME}/Result_development/* Result_development/; cd - > /dev/null
  chown -R oacis:oacis /home/oaics/oacis/public/Result_development
  cd /home/oacis/oacis/public/Result_development/db/`cd /home/oacis/oacis/public/Result_development/db; ls | grep dump | sort | tail -n 1`/oacis_development; mongorestore --db oacis_development .; cd - > /dev/null
else
  echo "tutorial(${TUTORIAL_NAME}) has been restored. start oacis without tutorials."
fi

