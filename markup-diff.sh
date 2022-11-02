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
DESTINATION=$(pwd)
URL="$1"

if [ "$2" != "" ]; then
    DESTINATION="$1"
    URL="$2"
elif [ "$1" == "" ]; then
    echo "error: expected at least a URL!"
    exit 1
fi

# resolve path, create if needed, then go there
DESTINATION=$(realpath "$DESTINATION")
mkdir -p "$DESTINATION"
cd "$DESTINATION"

# check if there is a git repo
git status &> /dev/null
GIT_EXISTS=$?
if [[ $GIT_EXISTS -ne 0 ]]; then
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
echo "destination: $DESTINATION"

# clean anything that exists in the directory so theres's no "left-overs" contaminating things
rm -fr *
echo "working directory clean..."
echo ""
echo "scraping site. This will take a while..."

if [[ ! -f ./.gitignore ]]; then
    echo "hts-*" >> ./.gitignore
    echo ".DS_Store" >> ./.gitignore
elif ! grep -q "hts-*" .gitignore ; then
    echo "hts-*" >> ./.gitignore
    echo ".DS_Store" >> ./.gitignore
fi

# starting scrape
httrack "$URL" -w -O "$DESTINATION" -c8 -I0 --display --disable-security-limits -T4096 -'*wp-admin*' -'*wp-content*' -'*wp-json*' -'*wp-include*'

echo ""
echo "scrape complete"

git add --all .

echo "run \`git commit -m "some message"\` to commit the snapshot before reviewing "

# return user to previous location
cd "$LAST_WD"