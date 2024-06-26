#!/bin/sh
set -e -u

docker run --rm --interactive --tty \
  --name=opentofu \
  --workdir=/srv/workspace \
  --mount type=bind,source=.,target=/srv/workspace \
  ghcr.io/opentofu/opentofu:latest "$@"
