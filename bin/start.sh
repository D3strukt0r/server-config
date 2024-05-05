#!/bin/bash
set -e -u -o pipefail

# Script dir (https://stackoverflow.com/a/246128/4156752)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# "fluentd" must be started before all projects
PROJECTS_DIR=$(realpath "$SCRIPT_DIR/../prod")
cd $PROJECTS_DIR/fluentd
echo "Starting fluentd"
docker compose up -d

# start all the other projects
PROJECTS=$(ls $PROJECTS_DIR | egrep -v '^fluentd$|disabled')
for PROJECT in $PROJECTS
do
    cd $PROJECTS_DIR/$PROJECT
    echo "Starting $PROJECT"
    docker compose up -d
done

PROJECTS_DIR=$(realpath "$SCRIPT_DIR/../dev")
PROJECTS=$(ls $PROJECTS_DIR | egrep -v 'disabled')
for PROJECT in $PROJECTS
do
    cd $PROJECTS_DIR/$PROJECT
    echo "Starting $PROJECT"
    docker compose up -d
done
