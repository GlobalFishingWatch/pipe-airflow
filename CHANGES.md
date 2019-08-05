# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a
Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## v1.0.0 - 2019-08-05

### Added

* [GFW-Tasks/issues/1100](https://github.com/GlobalFishingWatch/GFW-Tasks/issues/1100): Adds
  Update of airflow from 1.10.1 to 1.10.2
  CLOUD_SDK_VERSION was updated from 198.0.0 to 248.0.0
  The `tzlocal` library has deployed a new version on 23rd of July, the
  version `2.0.0` (https://pypi.org/project/tzlocal/2.0.0/#history). This lib
  brokes the compilation. Apache Airflow requires the `tzlocal` and
  `pendulum` libraries to be installed. In the `setup.py` file, the section
  `install_requires`, appears the dependencies and the lib `tzlocal>=1.4` and
  `pendulum==1.4.4`
  (https://github.com/apache/airflow/blob/1.10.2/setup.py#L337). The
  `pendulum` lib brokes with lib `tzlocal==2.0.0`, so right now I pinned to
  the previous version, the `1.5.1`.
  Removing the `pipe-tools` dependency in pipe-airflow. This library will be
  used for projects that will run inside airflow.

## v0.3.0 - 2019-03-08

### Added

* [GFW-Tasks/issues/968](https://github.com/GlobalFishingWatch/GFW-Tasks/issues/968): Changes
  making pipe-tools master up to date replacing the
  [pipe-tools](https://github.com/GlobalFishingWatch/pipe-tools) lib with the
  [airflow-gfw](https://github.com/GlobalFishingWatch/airflow-gfw) lib

## v0.2.9 - 2019-03-07

### Added

* [GFW-Tasks/issues/912](https://github.com/GlobalFishingWatch/GFW-Tasks/issues/912): Adds
  The number of task instances allowed to run concurrently was reduced to 3.
  Using 16 instances restarts the web pod recursively.
  Adds kubernetes section in `airflow.cfg`
  Adds authentication step before installing DAGs to let pull images from grc.io repo.

### Added

* [#884](https://github.com/GlobalFishingWatch/GFW-Tasks/issues/884): Adds
  Migrates Airflow version to 1.10.1 on pipe-tools.
  Uses `postgres` instead of `mysql`, because the property specified here
  (https://github.com/apache/incubator-airflow/blob/master/UPDATING.md#mysql-setting-required)
  could not be changed in CloudSQL.
  Update the pipe-tools version to 1.0.0.
