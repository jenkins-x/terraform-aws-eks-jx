#!/usr/bin/env bash
#
# Script to release a new Terraform Module version.
# The script exepct the version to release in the format v<major>.<minor>.<patch>.
# It then creates and pushes the tag and updates the GitHub changelog.

set -e

# check version is passed and sanity check semantic format
if [ $# -ne 1 ]; then
    echo "Usage: $0 <release-version>" >&2
    exit 1
fi

version=$1
echo $version | grep -q 'v[0-9]\+\.[0-9]\+\.[0-9]\+' || (echo "Specified release version '$version' is not semantic" >&2; exit 1)

# make sure we are on  master and have no uncommited changes
branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$branch" != "issue-47" ]; then
    echo "You need to be on master to release" >&2
    exit 1
fi

git diff-index --quiet HEAD -- || (echo "There are uncommited changes on branch '$branch'" >&2; exit 1)
 
# create and push tag; this will create GitHub release 
git tag -a $version -m "release $version"
git push --follow-tags

# create changelog by determining the commits between the last to tags
# use 'git merge-base' in case the tags occured on a detached head
prev_tag=$(git for-each-ref --sort=-creatordate --format="%(objectname)" refs/tags | sed -n 2p)
prev_tag_base=$(git merge-base $prev_tag master)
current_tag=$(git for-each-ref --sort=-creatordate --format="%(objectname)" refs/tags | sed -n 1p)
current_tag_base=$(git merge-base $current_tag master)

# actual changelog creation
jx step changelog -p $prev_tag_base -r $current_tag_base --generate-yaml=false --no-dev-release --update-release=true
