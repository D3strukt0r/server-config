#!/bin/sh
set -e -u

dockerfile="$1"
shift

docker run --rm --interactive hadolint/hadolint hadolint "$@" - < "$dockerfile"
