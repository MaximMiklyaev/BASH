#!/bin/bash

LOCKFILE=/var/log/nginx/pochta.sh
#LOCKFILE=/var/log/x
if [ -f $LOCKFILE ]
then
  echo "Lockfile active, no new runs."
  exit 1 
else
  echo "PID: $$" > $LOCKFILE
  trap 'rm -f $LOCKFILE"; exit $?' INT TERM EXIT
  echo "Simulate some activity..."
  rm -f $LOCKFILE
  trap - INT TERM EXIT
fi

