#!/usr/bin/env bash

BRANCH=dev # default
TAG_SUFFIX='' # default

# This script assumes that the package.json (version info) and the CHANGELOG are in the same directory.

# Load the package name and current version from ./package.json
PACKAGE=`node -p "require('./package.json').name"`
CURRENT_VERSION=`node -p "require('./package.json').version"`

# Parse the command line arguments and assign to variables
# -b: branch (default: master)
# -s: tag suffix (default: '')
while getopts b:s: flag
do
    case "${flag}" in
        b) BRANCH=${OPTARG};;
        s) TAG_SUFFIX=${OPTARG};;
    esac
done

# Check if this is an alpha, beta, or latest package and run the appropriate tagging command
if grep -q "alpha" <<< "$CURRENT_VERSION" || grep -q "beta" <<< "$CURRENT_VERSION";
then
    echo "This is an alpha or beta version - skipping tag."
    exit 0;
else
    # If this is not the master branch, do not do any tagging
    if ! [ $BRANCH == "master" ];
    then
        echo "This is not the master branch - skipping tag."
        exit 0;
    fi

    # If this is the master branch (or running locally without a -b flag), allow tagging
    echo "Tagging new latest";

    # Create tag-specific CHANGELOG, catch error.
    PARSE_SCRIPT_RESPONSE=`node node_modules/@pxblue/tag/scripts/parse-changelog.js $CURRENT_VERSION`
    echo $PARSE_SCRIPT_RESPONSE;
    if grep -q "Error" <<< "$PARSE_SCRIPT_RESPONSE"
    then
      echo "Error writing TAG_CHANGELOG.md"
      exit 0;
    fi

    # Use Github CLI to make a new release
    gh release create "v$CURRENT_VERSION$TAG_SUFFIX" -F TAG_CHANGELOG.md -t "$PACKAGE v$CURRENT_VERSION" --target master
fi
