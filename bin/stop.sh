#!/bin/bash
set -e -u -o pipefail

# Script dir (https://stackoverflow.com/a/246128/4156752)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

PROJECTS_DIR=$(realpath "$SCRIPT_DIR/../dev")
PROJECTS=$(ls $PROJECTS_DIR)
for PROJECT in $PROJECTS
do
    cd $PROJECTS_DIR/$PROJECT
    docker compose down
done

# stop all projects except "fluentd"
PROJECTS_DIR=$(realpath "$SCRIPT_DIR/../prod")
PROJECTS=$(ls $PROJECTS_DIR | sed 's/fluentd//')
for PROJECT in $PROJECTS
do
    cd $PROJECTS_DIR/$PROJECT
    docker compose down
done

# "fluentd" must be stopped after all projects are shut down
cd $PROJECTS_DIR/fluentd
docker compose down
