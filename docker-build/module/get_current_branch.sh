#!/bin/bash

set -e

# get current branch
BRANCH=$(git branch --show-current)
if [ -z "$BRANCH" ]; then
  BRANCH=$(git describe --tags)
fi

echo "{\"branch\": \"$BRANCH\"}"
