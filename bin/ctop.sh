#!/bin/sh
set -e -u

docker run --rm --interactive --tty \
  --name=ctop \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  quay.io/vektorlab/ctop:latest
