#!/bin/bash
set -e -u -o pipefail
IFS=$'\n\t'

if [ -f /etc/default/docker-services ]; then
  . /etc/default/docker-services
fi

ENVIRONMENT_DIR="$REPO_DIR/$SERVER_ENVIRONMENT"
