#!/usr/bin/env bash
TRY_LOOP=10

echo "Running airflow $1"

# wait for DB
echo "Waiting until database is ready at ${MYSQL_SERVICE_HOST}:${MYSQL_SERVICE_PORT}"
i=0
while ! nc -v -w 5 $MYSQL_SERVICE_HOST $MYSQL_SERVICE_PORT < /dev/null; do
  i=`expr $i + 1`
  if [ $i -ge $TRY_LOOP ]; then
    echo "$(date) - ${MYSQL_SERVICE_HOST}:${MYSQL_SERVICE_PORT} still not reachable, giving up"
    exit 1
  fi
  echo "$(date) - waiting for ${MYSQL_SERVICE_HOST}:${MYSQL_SERVICE_PORT}... $i/$TRY_LOOP"
  sleep 5
done
echo "Database is ready at ${MYSQL_SERVICE_HOST}:${MYSQL_SERVICE_PORT}"
