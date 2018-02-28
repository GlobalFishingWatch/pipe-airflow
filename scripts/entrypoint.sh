#!/usr/bin/env bash
TRY_LOOP=10

echo "Running pipe-airflow $1"

if [ "$1" = "webserver" ] || [ "$1" = "worker" ] || [ "$1" = "scheduler" ] ; then
  exec airflow "$@"
else
  exec ./scripts/$@
fi
