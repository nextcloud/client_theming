#!/bin/bash

# Adapted from the Debian travis-build.sh to test building a Windows binary
# according to the build instructions in README.md

set -xe
shopt -s extglob

TRAVIS_BUILD_STEP="$1"

if [ "$TRAVIS_BUILD_STEP" == "install" ]; then
    # @TODO: This patch updates the repo location of mingw _in the origin repo_
    # because repositories/windows:/mingw/openSUSE_42.1/windows:mingw.repo has
    # been moved to openSUSE Leap 42.1. This has been applied upstream but is
    # not included in their 2.3.3 tag. This should be removed and the patch
    # deleted when it is no longer needed to build, presumably in the next
    # release. See owncloud/client at 6be122e (PR owncloud/client#5900).
    cd client
    patch -p1 < ../win/opensuse-mingw-repo-location.patch
    cd ..
    # /end patch

elif [ "$TRAVIS_BUILD_STEP" == "script" ]; then
    read basever kind <<<$(linux/debian/scripts/git2changelog.py /tmp/tmpchangelog stable)

    docker build -t nextcloud-client-win32:${basever} client/admin/win/docker/
    docker run -v "$PWD:/home/user/" nextcloud-client-win32:${basever} /home/user/win/build.sh $(id -u)
fi
