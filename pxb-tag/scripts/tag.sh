#!/usr/bin/env bash

BRANCH=dev # default

# This script assumes that the package.json (version info) and the CHANGELOG are in the same directory.

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
if grep -q "alpha" <<< "$CURRENT_VERSION" || grep -q "beta" <<< "$CURRENT_VERSION";
then
    echo "This is an alpha or beta version - skipping tag."
    exit 0;
else
    # If this is not the master branch, do not do any 'latest' publications
    if [ $BRANCH == "master" ];
    # if ! [ $BRANCH == "master" ];
    then
        echo "This is not the master branch - skipping tag."
        exit 0;
    fi

    # If this is the master branch (or running locally without a -b flag), allow publishing a latest package
#    if [ $CURRENT_VERSION == $NPM_LATEST_VERSION ];
    if ! [ $CURRENT_VERSION == $NPM_LATEST_VERSION ];

    then
        echo "Tagging new latest";

        # Create tag-specific CHANGELOG, catch error.
        PARSE_SCRIPT_RESPONSE=`node script/parse-changelog.js $CURRENT_VERSION`
        echo $PARSE_SCRIPT_RESPONSE;
        if grep -q "Error" <<< "$PARSE_SCRIPT_RESPONSE"
        then
          echo "Error writing TAG_CHANGELOG.md"
          exit 0;
        fi

        echo $TAG_CHANGELOG_SUCCESS
        # Install Github CLI
        sudo apt-get update
        sudo apt install apt-transport-https
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh

        # Use Github CLI to make a new release
        gh release create $CURRENT_VERSION -F TAG_CHANGELOG.md
    else
        echo "Latest version is already published."
    fi
fi