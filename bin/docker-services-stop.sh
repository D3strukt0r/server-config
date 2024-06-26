#!/bin/bash
set -e -u -o pipefail
IFS=$'\n\t'

if [ -f /etc/default/docker-services ]; then
  . /etc/default/docker-services
fi

ENVIRONMENT_DIR="$REPO_DIR/$SERVER_ENVIRONMENT"

# https://stackoverflow.com/questions/75101230/find-for-yml-and-yaml-files-on-bash-find
# https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash/54561526#54561526
readarray -d '' DOCKER_COMPOSE_PATHS < <(find "$ENVIRONMENT_DIR" -regextype egrep -regex '.*ya?ml$' -print0)

#echo "${DOCKER_COMPOSE_PATHS[@]}"

# https://stackoverflow.com/questions/29225972/validating-docker-compose-yml-file
# https://stackoverflow.com/questions/3578584/bash-how-to-delete-elements-from-an-array-based-on-a-pattern
# filter out all invalid yaml files
for i in "${!DOCKER_COMPOSE_PATHS[@]}"; do
    dc_path="${DOCKER_COMPOSE_PATHS[$i]}"
    if ! docker compose -f "$dc_path" config > /dev/null 2>&1; then
        unset -v 'DOCKER_COMPOSE_PATHS[$i]'
    fi
done

#echo "${DOCKER_COMPOSE_PATHS[@]}"
