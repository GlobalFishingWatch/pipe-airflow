#!/usr/bin/env bash
TRY_LOOP=10

echo "Running airflow $1"

# wait for DB
if [ "$1" = "webserver" ] || [ "$1" = "worker" ] || [ "$1" = "scheduler" ] ; then
  echo "Waiting until database is ready at ${MYSQL_HOST}:${MYSQL_PORT}"
  i=0
  while ! nc -v -w 5 $MYSQL_HOST $MYSQL_PORT < /dev/null; do
    i=`expr $i + 1`
    if [ $i -ge $TRY_LOOP ]; then
      echo "$(date) - ${MYSQL_HOST}:${MYSQL_PORT} still not reachable, giving up"
      exit 1
    fi
    echo "$(date) - waiting for ${MYSQL_HOST}:${MYSQL_PORT}... $i/$TRY_LOOP"
    sleep 5
  done
  echo "Database is ready at ${MYSQL_HOST}:${MYSQL_PORT}"
  if [ "$1" = "webserver" ]; then
    echo "Initialize database..."
    airflow initdb
  fi
  sleep 5
fi

exec airflow "$@"
