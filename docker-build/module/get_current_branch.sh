#!/bin/bash

set -e

# get current branch
BRANCH=$(git branch --show-current)

echo "{\"branch\": \"$BRANCH\"}"
