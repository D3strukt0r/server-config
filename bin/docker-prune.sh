#!/bin/bash
set -e -u -o pipefail

start=$(date +%s)
echo "========== Start $0 =========="

docker system prune --force --filter "until=24h"

end=$(date +%s)
runtime=$((end-start))
echo "Script $0 took $runtime seconds"
echo "========== End $0 =========="
