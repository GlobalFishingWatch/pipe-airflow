#!/usr/bin/env bash

echo "Initialize airflow database"
airflow initdb

echo "Initialize standard variables"
airflow variables --set DATAFLOW_WRAPPER_LOG_PATH "/airflow/log_wrapper"
airflow variables --set DATAFLOW_WRAPPER_STUB "/airflow/utils/log_wrapper.py"
airflow variables --set DOCKER_RUN "gcloud docker -- run"
airflow variables --set GCP_PROJECT_ID $GCP_PROJECT_ID
airflow variables --set PROJECT_ID $PROJECT_ID
airflow variables --set TEMP_BUCKET $TEMP_BUCKET
airflow variables --set PIPELINE_BUCKET $PIPELINE_BUCKET
airflow variables --set PIPELINE_DATASET $PIPELINE_DATASET
airflow variables --set PIPELINE_START_DATE $PIPELINE_START_DATE

echo "Initialize worker pools"
airflow pool -s dataflow 1 "Google Cloud Dataflow jobs"
airflow pool -s bigquery 1 "Google Bigquery jobs"

echo "Install dags"
utils/install_dag.sh "gcr.io/world-fishing-827/github-globalfishingwatch-pipe-measures:v0.1.2"

