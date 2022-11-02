#!/usr/bin/env bash

    
# check tools
if ! command -v httrack &> /dev/null; then
    echo "error: httrack is not installed. Try installing via \`brew install httrack\`"
    exit 1
fi
if ! command -v realpath &> /dev/null; then
    echo "error: realpath is not installed. Try installing via \`brew install coreutils\`"
    exit 1
fi

# check args
LAST_WD=$(pwd)
BASE_DIR=$(pwd)
URL="$1"

if [ "$2" != "" ]; then
    BASE_DIR="$1"
    URL="$2"
elif [ "$1" == "" ]; then
    echo "error: expected at least a URL!"
    exit 1
fi

# resolve path, create if needed, then go there
BASE_DIR=$(realpath "$BASE_DIR")
mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

# check if there is a git repo
git status &> /dev/null

if [[ $INSTALL_EXITCODE -ne 0 ]]; then
    echo "error: this needs to be tracked by git. Try creating an new git repo via \`git init\`"
    cd "$LAST_WD"
    exit 1
fi

if [[ -n $(git status --porcelain) ]]; then
    echo "error: git has uncommitted changes. Please commit them before continuing."
    cd "$LAST_WD"
    exit 1
fi 

echo "scrape: $URL"
echo "destination: $BASE_DIR"

# return user to previous location
cd "$LAST_WD"