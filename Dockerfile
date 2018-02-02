FROM debian:jessie

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.9.0
ENV AIRFLOW_HOME /usr/local/airflow

RUN set -ex \
    && buildDeps=' \
        python-pip \
        python-dev \
        libkrb5-dev \
        libsasl2-dev \
        libxml2-dev \
        libssl-dev \
        libffi-dev \
        build-essential \
        libblas-dev \
        liblapack-dev \
        libxslt1-dev \
        zlib1g-dev \
        libmysqlclient-dev \
    ' \
    && echo "deb http://http.debian.net/debian jessie-backports main" >/etc/apt/sources.list.d/backports.list \
    && apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        apt-utils \
        curl \
        netcat \
    && apt-get install -yqq -t jessie-backports python-requests \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && pip uninstall setuptools \
    && pip install setuptools==33.1.1 \
    && pip install pytz==2015.7 \
    && pip install cryptography \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install apache-airflow[mysql,crypto]==$AIRFLOW_VERSION \
    && apt-get remove --purge -yqq $buildDeps libpq-dev \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg
COPY scripts/entrypoint.sh ${AIRFLOW_HOME}/entrypoint.sh

RUN chown -R airflow: ${AIRFLOW_HOME} && chmod +x ${AIRFLOW_HOME}/entrypoint.sh

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["./entrypoint.sh"]
