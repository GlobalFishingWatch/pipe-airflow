FROM docker:17.12.0-ce as static-docker-source

FROM python:3.7.6-slim-buster

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow configuration
ENV AIRFLOW_VERSION 1.10.10
ENV AIRFLOW_HOME /usr/local/airflow
ENV SLUGIFY_USES_TEXT_UNIDECODE=yes

#Airflow-gfw
ENV AIRFLOW_GFW_VERSION v1.0.4

# Use the docker binary from the other source
COPY --from=static-docker-source /usr/local/bin/docker /usr/local/bin/docker

# Download and install google cloud. See the dockerfile at
# https://hub.docker.com/r/google/cloud-sdk/~/dockerfile/
ENV CLOUD_SDK_VERSION 300.0.0
RUN apt-get -qqy update && apt-get install -qqy \
        gnupg \
        curl \
        gcc \
        python-dev \
        python-setuptools \
        apt-transport-https \
        lsb-release \
        openssh-client \
        git \
    && easy_install -U pip && \
    pip install -U crcmod   && \
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version

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
        iptables \
        init-system-helpers \
        libapparmor1 \
        libltdl7 \
        nano \
    && useradd -ms /bin/bash -u 1001 -d ${AIRFLOW_HOME} airflow \
    && python -m pip install -U pip setuptools wheel \
    && pip install marshmallow-sqlalchemy==0.22.3 \
    && pip install Cython \
    && pip install cryptography \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install celery[redis] \
    && pip install sqlalchemy==1.3.15 \
    && pip install apache-airflow[postgres,crypto,celery,jdbc]==$AIRFLOW_VERSION \
    && pip install psycopg2-binary \
    && pip install 'werkzeug<1.0.0' \
    && apt-get remove --purge -yqq $buildDeps libpq-dev \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

# Setup pipeline debugging tools
RUN pip install https://github.com/GlobalFishingWatch/airflow-gfw/archive/${AIRFLOW_GFW_VERSION}.tar.gz

# Setup airflow home directory
WORKDIR ${AIRFLOW_HOME}
COPY config/* ${AIRFLOW_HOME}/
COPY scripts/* ${AIRFLOW_HOME}/
COPY utils/* ${AIRFLOW_HOME}/utils/
RUN mkdir ${AIRFLOW_HOME}/dags
RUN mkdir ${AIRFLOW_HOME}/log_wrapper

# Setup user settings
RUN chown -R airflow: ${AIRFLOW_HOME}
USER airflow

EXPOSE 8080 5555 8793
ENTRYPOINT ["./entrypoint"]
