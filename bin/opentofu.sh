#!/bin/sh
set -e -u
docker run --rm -ti \
  --name=opentofu \
  --workdir=/srv/workspace \
  --mount type=bind,source=.,target=/srv/workspace \
  ghcr.io/opentofu/opentofu:latest "$@"
