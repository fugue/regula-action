#!/bin/bash

jq --version
opa version
terraform version

echo "$GITHUB_WORKSPACE"
ls -a "$GITHUB_WORKSPACE"
