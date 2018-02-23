FROM python:3.6-slim

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow configuration
ARG AIRFLOW_VERSION=1.9.0
ENV AIRFLOW_HOME /usr/local/airflow
WORKDIR ${AIRFLOW_HOME}

# Install airflow and it's dependencies
RUN set -ex \
    && buildDeps=' \
        python3-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        build-essential \
        libblas-dev \
        liblapack-dev \
        libpq-dev \
        libmysqlclient-dev \
        git \
    ' \
    && apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        python3-pip \
        python3-requests \
        apt-utils \
        curl \
        netcat \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && python -m pip install -U pip setuptools wheel \
    && pip install Cython \
    && pip install cryptography \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install celery[redis] \
    && pip install apache-airflow[mysql,crypto,celery,jdbc]==$AIRFLOW_VERSION \
    && apt-get remove --purge -yqq $buildDeps libpq-dev \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

# Setup airflow home directory
COPY config/* ${AIRFLOW_HOME}/
COPY scripts/* ${AIRFLOW_HOME}/
COPY utils/* ${AIRFLOW_HOME}/utils/
RUN mkdir ${AiRFLOW_HOME}/dags

# Setup user settings
RUN chown -R airflow: ${AIRFLOW_HOME}
USER airflow

EXPOSE 8080 5555 8793
ENTRYPOINT ["./entrypoint.sh"]
