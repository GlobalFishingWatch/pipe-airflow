#!/usr/bin/env bash

echo "Initialize airflow database"
airflow initdb

echo "Initialize standard variables"
airflow variables --set DATAFLOW_WRAPPER_LOG_PATH "/airflow/log_wrapper"
airflow variables --set DATAFLOW_WRAPPER_STUB "/airflow/utils/log_wrapper.py"
airflow variables --set DOCKER_RUN "gcloud docker -- run"
airflow variables --set GCP_PROJECT_ID "world-fishing-827"
airflow variables --set PIPELINE_BUCKET "pipe-staging-a"
airflow variables --set PIPELINE_DATASET "pipe_staging_a"
airflow variables --set PIPELINE_START_DATE "2017-01-01"
airflow variables --set PROJECT_ID "world-fishing-827"
airflow variables --set TEMP_BUCKET "pipe-temp-a-ttl3"


echo "Initialize worker pools"
airflow pool -s dataflow 1 "Google Cloud Dataflow jobs"
airflow pool -s bigquery 1 "Google Bigquery jobs"

