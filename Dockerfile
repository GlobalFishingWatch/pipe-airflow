FROM python:2.7-slim

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
        iptables \
        init-system-helpers \
        libapparmor1 \
        libltdl7 \
        nano \
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

# Install docker (from https://docs.docker.com/engine/installation/linux/docker-ce/debian/#upgrade-docker-ce and
#                  and https://github.com/docker-library/docker/blob/master/Dockerfile.template)
RUN curl -L -o docker.deb \
       "https://download.docker.com/linux/debian/dists/jessie/pool/stable/amd64/docker-ce_17.03.2~ce-0~debian-jessie_amd64.deb" \
  && dpkg -i docker.deb

# Download and install google cloud. See the dockerfile at
# https://hub.docker.com/r/google/cloud-sdk/~/dockerfile/
RUN  \
  export CLOUD_SDK_APT_DEPS="curl gcc python-dev python-setuptools apt-transport-https lsb-release openssh-client git" && \
  export CLOUD_SDK_PIP_DEPS="crcmod" && \
  apt-get -qqy update && \
  apt-get install -qqy $CLOUD_SDK_APT_DEPS && \
  pip install -U $CLOUD_SDK_PIP_DEPS && \
  export CLOUD_SDK_VERSION="184.0.0" && \
  export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
  echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
  apt-get update && \
  apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 && \
  gcloud config set core/disable_usage_reporting true && \
  gcloud config set component_manager/disable_update_check true && \
  gcloud config set metrics/environment github_docker_image

RUN pip install https://codeload.github.com/GlobalFishingWatch/pipe-tools/tar.gz/v0.1.5a

# Setup airflow home directory
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
