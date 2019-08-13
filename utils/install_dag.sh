#!/bin/bash

# Arguments: CONTAINER_NAME 
#
# CONTAINER_NAME : path to the docker image
#
#  For example, an image in google container engine
#    gcr.io/PROJECT_ID/github-globalfishingwatch-anchorages_pipeline:test-image-building
#  Or a local image
#    gfw/anchorages_pipeline:latest
#

set -e

display_usage() {
	echo "Usage "
	echo "  $0 DOCKERIMAGE [post-install-args]"
	}

is_docker_daemon_up() {
  local TRY_LOOP=10
  local DOCKER_DEAMON_HOST=$(echo $DOCKER_HOST | sed 's/tcp:\/\/\([^:]*\).*/\1/')
  local DOCKER_DEAMON_PORT=$(echo $DOCKER_HOST | sed 's/.*:\([^:]*\)$/\1/')

  # wait for DockerDaemon
  echo "Waiting until Docker Daemon is ready at ${DOCKER_DEAMON_HOST}:${DOCKER_DEAMON_PORT}"
  i=0
  while ! nc -v -w 5 ${DOCKER_DEAMON_HOST} ${DOCKER_DEAMON_PORT} < /dev/null; do
    i=`expr $i + 1`
    if [ $i -ge $TRY_LOOP ]; then
      echo "$(date) - ${DOCKER_DEAMON_HOST}:${DOCKER_DEAMON_PORT} still not reachable, giving up"
      exit 1
    fi
    echo "$(date) - waiting for ${DOCKER_DEAMON_HOST}:${DOCKER_DEAMON_PORT}... $i/$TRY_LOOP"
    sleep 5
  done
  echo "Docker Daemon is ready at ${DOCKER_DEAMON_HOST}:${DOCKER_DEAMON_PORT}"
}


if [[ $# -le 0 ]]
then
    display_usage
    exit 1
fi

IFS=':' read -ra PARTS <<< "$1"
IFS='/' read -ra PARTS <<< "${PARTS[0]}"
IMAGE=${PARTS[${#PARTS[@]}-1]}

CONTAINER=$1
AIRFLOW_DAG_PATH=${AIRFLOW_HOME}/dags/${IMAGE}
CONTAINER_DAG_PATH=/dags
POST_INSTALL=${AIRFLOW_DAG_PATH}/post_install.sh


is_docker_daemon_up

if [ -z $DOCKER_USE_LOCAL ]; then
  echo "Updating docker image"
  echo "  Container: $CONTAINER"

  gcloud docker -- pull $CONTAINER
fi

echo "Creating dag install folder"
echo "  Local path: $AIRFLOW_DAG_PATH"
echo "  Container path: $CONTAINER_DAG_PATH"

mkdir -p $AIRFLOW_DAG_PATH

echo ""
echo "Installing Dags"
echo "  Container: $CONTAINER"

gcloud docker -- run --entrypoint=/bin/bash -v $AIRFLOW_DAG_PATH:$CONTAINER_DAG_PATH $CONTAINER install.sh


echo ""
echo "Executing post install"
echo "  Script: $POST_INSTALL"

/bin/bash $POST_INSTALL "$@"

echo ""
echo "Done"

