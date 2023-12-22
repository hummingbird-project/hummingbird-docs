#!/bin/bash

echo "Use GitHub action publish.yml instead of running this script"
exit

# stash everything that isn't in docs, store result in STASH_RESULT
STASH_RESULT=$(git stash -- ":(exclude)docs")
# get branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
REVISION_HASH=$(git rev-parse HEAD)

rm -rf _docs
mv docs/hummingbird-docs/2.0 _docs
git checkout gh-pages
git pull
# copy contents of docs to docs/current replacing the ones that are already there
rm -rf docs/2.0
mv _docs/hummingbird-docs docs/2.0
# commit
git add --all docs/2.0

git status
#git commit -m "Documentation for https://github.com/hummingbird-project/hummingbird-docs/tree/$REVISION_HASH"
#git push
# return to branch
git checkout "$CURRENT_BRANCH"

if [ "$STASH_RESULT" != "No local changes to save" ]; then
    git stash pop
fi

