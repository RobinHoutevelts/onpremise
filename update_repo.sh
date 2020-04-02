#!/usr/bin/env bash

#############################################################################
#                                                                           #
# A simple bash script to fetch the changes made by the core sentry team    #
#   ./update_repo.sh                                                        #
#                                                                           #
#############################################################################

set -e

SOURCE_NAME="source"
SOURCE_BRANCH="master"
SOURCE_ORIGIN="git@github.com:getsentry/onpremise.git" #The 'real' origin of the source ( the sentry repo )

if ! git ls-remote --exit-code "$SOURCE_NAME" > /dev/null 2>&1; then
    echo "Sentry remote $SOURCE_NAME not found. Adding it"
    git remote add "$SOURCE_NAME" "$SOURCE_ORIGIN"
fi

git fetch "$SOURCE_NAME" > /dev/null 2>&1

git merge "$SOURCE_NAME/$SOURCE_BRANCH"
