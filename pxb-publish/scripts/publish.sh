#!/usr/bin/env bash

BRANCH=`dev` # default

# Load the package name and current version from ./package.json
PACKAGE=`node -p "require('./package.json').name"`
CURRENT_VERSION=`node -p "require('./package.json').version"`

# Parse the command line arguments and assign to variables
# -b: branch (default: master)
while getopts b: flag
do
    case "${flag}" in
        b) BRANCH=${OPTARG};;
    esac
done

NPM_LATEST_VERSION=`npm show ${PACKAGE} version`
NPM_BETA_VERSION=`npm show ${PACKAGE}@beta version`
NPM_ALPHA_VERSION=`npm show ${PACKAGE}@alpha version`

# Check if this is an alpha, beta, or latest package and run the appropriate publishing command
if grep -q "alpha" <<< "$CURRENT_VERSION";
then
    if ! [ $CURRENT_VERSION == $NPM_ALPHA_VERSION ];
    then
        echo "Publishing new alpha";
        npm publish --tag alpha
    else
        echo "Alpha version is already published."
    fi
elif grep -q "beta" <<< "$CURRENT_VERSION";
then
    if ! [ $CURRENT_VERSION == $NPM_BETA_VERSION ];
    then
        echo "Publishing new beta";
        npm publish --tag beta
    else
        echo "Beta version is already published."
    fi
else
    # If this is not the master branch, do not do any 'latest' publications
    if ! [ $BRANCH == "master" ];
    then
        echo "This is not the master branch - skipping publishing."
        exit 0;
    fi

    # If this is the master branch (or running locally without a -b flag), allow publishing a latest package
    if ! [ $CURRENT_VERSION == $NPM_LATEST_VERSION ];
    then
        echo "Publishing new latest";
        npm publish
    else
        echo "Latest version is already published."
    fi
fi