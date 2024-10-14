#!/bin/bash
set -e -u -o pipefail

start=$(date +%s)
echo "========== Start $0 =========="

# Script dir (https://stackoverflow.com/a/246128/4156752)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Change to repo root, is recommended by restic docs
cd "$SCRIPT_DIR/.."

# Read environment variables
. .restic-env

restic backup . --skip-if-unchanged \
    --exclude 'backup/**'
restic forget --prune \
    --keep-hourly 24 \
    --keep-daily 7 \
    --keep-weekly 5 \
    --keep-monthly 12 \
    --keep-yearly 1

end=$(date +%s)
runtime=$((end-start))
echo "Script $0 took $runtime seconds"
echo "========== End $0 =========="
