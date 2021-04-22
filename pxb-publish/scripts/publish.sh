#!/usr/bin/env bash

branch=master # default
package="";

# Parse the command line arguments and assign to variables
# -p: package name
# -b: branch (default: master)
while getopts p:b: flag
do
    case "${flag}" in
        p) package=${OPTARG};;
        b) branch=${OPTARG};;
    esac
done

# MASTER_VERSION=`node -p "require('./package.json').version"`
NPM_LATEST_VERSION=`npm show ${package} version`
NPM_BETA_VERSION=`npm show ${package}@beta version`
NPM_ALPHA_VERSION=`npm show ${package}@alpha version`

# Check if this is an alpha, beta, or latest package and run the appropriate publishing command
if grep -q "alpha" <<< "$MASTER_VERSION";
then
    if ! [ $MASTER_VERSION == $NPM_ALPHA_VERSION ];
    then
        echo "Publishing new alpha";
        npm publish --tag alpha
    else
        echo "Alpha version is already published."
    fi
elif grep -q "beta" <<< "$MASTER_VERSION";
then
    if ! [ $MASTER_VERSION == $NPM_BETA_VERSION ];
    then
        echo "Publishing new beta";
        npm publish --tag beta
    else
        echo "Beta version is already published."
    fi
else
    # If this is not the master branch, do not do any 'latest' publications
    if ! [ $branch == "master" ];
    then
        echo "This is not the master branch - skipping publishing."
        exit 0;
    fi

    # If this is the master branch (or running locally without a -b flag), allow publishing a latest package
    if ! [ $MASTER_VERSION == $NPM_LATEST_VERSION ];
    then
        echo "Publishing new latest";
        npm publish
    else
        echo "Latest version is already published."
    fi
fi