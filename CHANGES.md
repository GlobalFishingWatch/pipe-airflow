# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a
Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
  * [#884](https://github.com/GlobalFishingWatch/GFW-Tasks/issues/884):
    * Migrates Airflow version to 1.10.1 on pipe-tools.
    * Uses `postgres` instead of `mysql`, because the property specified here (https://github.com/apache/incubator-airflow/blob/master/UPDATING.md#mysql-setting-required) could not be changed in CloudSQL.
    * Update the pipe-tools version to 1.0.0.
