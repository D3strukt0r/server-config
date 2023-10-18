#!/bin/bash
set -e -u -o pipefail

# Script dir (https://stackoverflow.com/a/246128/4156752)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BACKUP_DIR=$SCRIPT_DIR/../backup/weekly

# Change to repo root, so that git command works
cd "$SCRIPT_DIR/.."

mkdir --parents "$BACKUP_DIR"
# Get all uncommited files, remove the "Would remove" prefix, filter out backup folder, and tar them
git clean -d -x --dry-run \
  | sed 's/^Would remove \(.*\)/\1/g' \
  | grep --invert-match "^backup" \
  | tar --create --gzip --file="$BACKUP_DIR/backup-$(date +%Y%m%d).tar.gz" -T -
find "$BACKUP_DIR/*" -mtime +31 -delete
