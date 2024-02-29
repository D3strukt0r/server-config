#!/bin/bash
set -e -u -o pipefail

start=`date +%s`

# Script dir (https://stackoverflow.com/a/246128/4156752)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BACKUP_DIR=$(realpath "$SCRIPT_DIR/../backup/monthly")

# Change to repo root, so that git command works
cd "$SCRIPT_DIR/.."

mkdir --parents "$BACKUP_DIR"
# Get all uncommited files, remove the "Would remove" prefix, filter out backup
# folder, and tar them. "|| true" fallback required, because "file changed as we
# read it" throws a return code of 1
git clean -d -x --dry-run \
  | sed 's/^Would remove \(.*\)/\1/g' \
  | grep --invert-match "^backup" \
  | tar --create --gzip --file="$BACKUP_DIR/backup-$(date +%Y%m%d).tar.gz" -T - || true
find "$BACKUP_DIR" -mtime +365 -delete

end=`date +%s`
runtime=$((end-start))
echo "Script $0 took $runtime seconds"
