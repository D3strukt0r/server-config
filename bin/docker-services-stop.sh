#!/bin/bash
set -e -u -o pipefail
IFS=$'\n\t'

if [ -f /etc/default/docker-services ]; then
  . /etc/default/docker-services
fi

ENVIRONMENT_DIR=$(realpath "$REPO_DIR/$SERVER_ENVIRONMENT")

# https://stackoverflow.com/questions/75101230/find-for-yml-and-yaml-files-on-bash-find
# https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash/54561526#54561526
readarray -d '' docker_compose_paths < <(find "$ENVIRONMENT_DIR" -regextype egrep -regex '.*ya?ml$' -print0)

# https://stackoverflow.com/questions/229551/how-to-check-if-a-string-contains-a-substring-in-bash/229585#229585
function stringContain() { case $2 in *$1* ) return 0;; *) return 1;; esac ;}

# https://stackoverflow.com/questions/29225972/validating-docker-compose-yml-file
# https://stackoverflow.com/questions/3578584/bash-how-to-delete-elements-from-an-array-based-on-a-pattern
FLUENTD_SERVICE_PATH=""
TRAEFIK_SERVICE_PATH=""
for i in "${!docker_compose_paths[@]}"; do
    docker_compose_path="${docker_compose_paths[$i]}"
    docker_compose_dir=$(dirname "$docker_compose_path")
    project_name=$(basename "$docker_compose_dir")
    if ! docker compose -f "$docker_compose_path" config > /dev/null 2>&1; then
        # filter out all invalid yaml files
        unset -v 'docker_compose_paths[$i]'
    # if the project has to do with fluentd or traefik, remove it and save
    # separately in different order
    elif stringContain fluentd "$project_name"; then
        FLUENTD_SERVICE_PATH="$docker_compose_path"
        unset -v 'docker_compose_paths[$i]'
    elif stringContain traefik "$project_name"; then
        TRAEFIK_SERVICE_PATH="$docker_compose_path"
        unset -v 'docker_compose_paths[$i]'
    fi
done
# append at end of list if fluentd or traefik service is found so it's stopped
# after all other services that may depend on it
if [ -n "$TRAEFIK_SERVICE_PATH" ]; then
    docker_compose_paths+=("$TRAEFIK_SERVICE_PATH")
fi
if [ -n "$FLUENTD_SERVICE_PATH" ]; then
    docker_compose_paths+=("$FLUENTD_SERVICE_PATH")
fi

for docker_compose_path in "${docker_compose_paths[@]}"; do
    docker_compose_dir=$(dirname "$docker_compose_path")
    docker_compose_file=$(basename "$docker_compose_path")
    (
        echo "Stopping $docker_compose_file in $docker_compose_dir"
        cd "$docker_compose_dir"
        docker compose -f "$docker_compose_file" down
    )
done
