#!/bin/bash

cd ${projectDir}

git remote add aws ${repositoryUrl}

git remote set-url aws ${repositoryUrl} # to make sure the url is correct, in case of a change

set -e

BRANCH=$(git branch --show-current)

#sleep 5 # wait 5s for the credentials to be ready the first time

PASSWORD=$(aws ssm get-parameter --name ${gitPasswordKey} \
  --with-decryption --query Parameter.Value --output text --no-cli-pager)
USERNAME="${gitUsername}"

git -c credential.helper= \
  -c credential.helper="!f() { echo \"username=$USERNAME\"; echo \"password=$PASSWORD\"; };f" \
  push aws "$BRANCH"
