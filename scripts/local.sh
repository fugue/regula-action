#!/bin/bash
set -o nounset -o errexit -o pipefail

# This script emulates the github action locally.  Pass it the directory that
# you want to test as a single parameter.

readlink_exe=readlink

if [[ $(uname -s) == "Darwin" ]]; then
    readlink_exe=greadlink
fi

WORKSPACE="$(${readlink_exe} -f "$1")"
echo "Using workspace $WORKSPACE..." 1>&2
shift 1

if [[ $# -lt 1 ]]; then
    INPUT_PATH="/github/workspace"
else
    INPUT_PATH="$@"
fi

echo "Updating docker image..." 1>&2
docker build -t regula-action .

echo "Running action..." 1>&2
docker run --rm \
    --volume "$WORKSPACE":/github/workspace \
    --volume "$HOME/.aws":/root/.aws \
    -e "GITHUB_WORKSPACE=/github/workspace" \
    -e "INPUT_INPUT_PATH=${INPUT_PATH}" \
    regula-action
