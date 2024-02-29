#!/bin/bash
set -e -u -o pipefail

start=`date +%s`

# Script dir (https://stackoverflow.com/a/246128/4156752)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

docker system prune --force --filter "until=24h"

end=`date +%s`
runtime=$((end-start))
echo "Script $0 took $runtime seconds"
