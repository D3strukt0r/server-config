#!/bin/sh
set -e -u

: "${PRIVATE_KEY_PATH:=$HOME/.ssh/id_ed25519}"
PRIVATE_KEY_FILE="$(basename "$PRIVATE_KEY_PATH")"
: "${PUBLIC_KEY_PATH:=$HOME/.ssh/id_ed25519.pub}"
PUBLIC_KEY_FILE="$(basename "$PUBLIC_KEY_PATH")"
: "${DIGITALOCEAN_ACCESS_TOKEN:?DIGITALOCEAN_ACCESS_TOKEN must be set}"

docker run --rm --interactive --tty \
  --env="DIGITALOCEAN_ACCESS_TOKEN=$DIGITALOCEAN_ACCESS_TOKEN" \
  --volume "$PRIVATE_KEY_PATH:/root/.ssh/$PRIVATE_KEY_FILE" \
  --volume "$PUBLIC_KEY_PATH:/root/$PUBLIC_KEY_FILE" \
  digitalocean/doctl "$@"
