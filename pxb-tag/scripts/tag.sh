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

NPM_LATEST_VERSION=`npm show ${PACKAGE} version`

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

    # Install Github CLI
    if ! [ -x "$(command -v gh)" ]; then
      echo 'Warning: gh is not installed; installing gh for linux' >&2
      sudo apt-get update
      sudo apt install apt-transport-https
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
      sudo apt update
      sudo apt install gh
    fi

    # Use Github CLI to make a new release
    gh release create "v$CURRENT_VERSION$TAG_SUFFIX" -F TAG_CHANGELOG.md -t "$PACKAGE v$CURRENT_VERSION"
fi
