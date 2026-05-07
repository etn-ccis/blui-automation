#!/usr/bin/env bash

# Copyright (c) 2021-present, Eaton
# All rights reserved.
# This code is licensed under the BSD-3 license found in the LICENSE file in the root directory of this source tree and at https://opensource.org/licenses/BSD-3-Clause.


BRANCH=dev # default
FIRST_TIME=false # is this the first time publishing the package?

# TEMPORARY RELEASE BRANCH RULES (ROLLBACK AFTER CURRENT RELEASE WINDOW):
# - Publish alpha/beta only from: dev or main
# - Publish stable (latest) only from: master or release-react-color
# Rollback hint: restore prerelease check to no branch restriction and latest check to master only.

# Load the package name and current version from ./package.json
PACKAGE=`node -p "require('./package.json').name"`
CURRENT_VERSION=`node -p "require('./package.json').version"`

# Parse the command line arguments and assign to variables
# -b: branch (default: dev)
while getopts b: flag
do
    case "${flag}" in
        b) BRANCH=${OPTARG};;
    esac
done

NPM_LATEST_VERSION=`npm show ${PACKAGE} version`
NPM_BETA_VERSION=`npm show ${PACKAGE}@beta version`
NPM_ALPHA_VERSION=`npm show ${PACKAGE}@alpha version`
if [ "$NPM_LATEST_VERSION" == "" ] 
then FIRST_TIME=true; 
fi;

# Check if this is an alpha, beta, or latest package and run the appropriate publishing command
if grep -q "alpha" <<< "$CURRENT_VERSION";
then
    # Temporary guard: only allow alpha from dev/main.
    if ! [[ "$BRANCH" == "dev" || "$BRANCH" == "main" ]];
    then
        echo "This branch is not allowed for alpha publishing - skipping publishing."
        exit 0;
    fi

    if ! [ "$CURRENT_VERSION" == "$NPM_ALPHA_VERSION" ];
    then
        echo "Publishing new alpha";
        if [ "$FIRST_TIME" == true ]
        then npm publish --tag alpha --access public
        else npm publish --tag alpha
        fi
    else
        echo "Alpha version is already published."
    fi
elif grep -q "beta" <<< "$CURRENT_VERSION";
then
    # Temporary guard: only allow beta from dev/main.
    if ! [[ "$BRANCH" == "dev" || "$BRANCH" == "main" ]];
    then
        echo "This branch is not allowed for beta publishing - skipping publishing."
        exit 0;
    fi

    if ! [ "$CURRENT_VERSION" == "$NPM_BETA_VERSION" ];
    then
        echo "Publishing new beta";
        if [ "$FIRST_TIME" = true ]
        then npm publish --tag beta --access public
        else npm publish --tag beta
        fi
    else
        echo "Beta version is already published."
    fi
else
    # Temporary guard: allow stable publishing from master or release-react-color only.
    if ! [[ "$BRANCH" == "master" || "$BRANCH" == "release-react-color" ]];
    then
        echo "This branch is not allowed for stable publishing - skipping publishing."
        exit 0;
    fi

    # If this is the master branch (or running locally without a -b flag), allow publishing a latest package
    if ! [ "$CURRENT_VERSION" == "$NPM_LATEST_VERSION" ];
    then
        echo "Publishing new latest";
        if [ "$FIRST_TIME" = true ]
        then npm publish --access public
        else npm publish
        fi
    else
        echo "Latest version is already published."
    fi
fi