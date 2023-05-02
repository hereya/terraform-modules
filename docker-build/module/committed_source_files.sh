#!/bin/bash

set -e

FILES=$(git ls-tree -r HEAD --name-only)
# convert FILES to json array
OUTPUT=""
for FILE in $FILES; do
  OUTPUT="${OUTPUT}${FILE},"
done
# remove trailing comma
OUTPUT=${OUTPUT%?}

echo "{\"files\": \"$OUTPUT\"}"
