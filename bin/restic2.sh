#!/bin/bash
set -e -u -o pipefail

# Script dir (https://stackoverflow.com/a/246128/4156752)
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$SCRIPT_DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

. "$ROOT_DIR/.restic-env"

# https://www.digitalocean.com/community/tutorials/how-to-back-up-data-to-an-object-storage-service-with-the-restic-backup-client

restic "$@"

# restic2 backup . --skip-if-unchanged

#docker run --rm --interactive --tty \
#  --env AWS_ACCESS_KEY_ID \
#  --env AWS_SECRET_ACCESS_KEY \
#  --env RESTIC_REPOSITORY \
#  --env RESTIC_PASSWORD \
#  --workdir=/srv/workspace \
#  --mount "type=bind,source=$ROOT_DIR,target=/srv/workspace" \
#  restic/restic:latest "$@"
