#!/bin/bash
set -o nounset -o errexit -o pipefail

# This script emulates the github action locally.  Pass it the directory that
# you want to test as a single parameter.

WORKSPACE="$(readlink -f "$1")"
echo "Using workspace $WORKSPACE..." 1>&2

echo "Updating docker image..." 1>&2
docker build -t regula-action .

echo "Running action..." 1>&2
docker run --rm \
    --user "$(id -u):$(id -g)" \
    --volume "$WORKSPACE":/github/workspace \
    -e "GITHUB_WORKSPACE=/github/workspace" \
    regula-action
