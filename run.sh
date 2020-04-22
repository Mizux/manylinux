#!/usr/bin/env bash

set -euxo pipefail

command -v docker

docker build --tag manylinux:python -f Dockerfile .
