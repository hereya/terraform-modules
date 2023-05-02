#!/bin/bash

set -e

# get last commit hash
LAST_COMMIT=$(git rev-parse --short HEAD)

echo "{\"hash\": \"$LAST_COMMIT\"}"
