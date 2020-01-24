#!/usr/bin/env bash

set -e

# Verify there's no uncommitted changes in the working dir
if [[ -n "$(git status --untracked-files=no --porcelain)" ]]; then
  >&2 printf "\nERR: working directory not clean.  Commit, or stash changes to continue.\n\n"
  exit 1
fi

VERSION=db-4.8.30.NC

if ! grep -q "${VERSION}" "./Dockerfile" ; then
  >&2 printf "\nERR: Requested version not present in Dockerfile. Make sure that's what you want to do.\n\n"
  exit 1
fi

git fetch --tags

# Get last build number
LAST=$(git tag | grep '+build' | sed 's|^.*build||' | sort -h | tail -n 1)
LAST=${LAST:-1}

# Increment it
((LAST++))

# Construct the full ${TAG}, ex: `db-4.8.30.NC+build666`
TAG="${VERSION}+build${LAST}"

printf "Creating tag: %s…\t" "${TAG}"
git tag -sa "${TAG}" -m "${TAG}"
echo "done"

printf "Pushing tag: %s…\t" "${TAG}"
git push origin "${TAG}"
echo "All done"
