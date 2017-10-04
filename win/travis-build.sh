#!/bin/bash

# Adapted from the Debian travis-build.sh to test building a Windows binary
# according to the build instructions in README.md

set -xe
shopt -s extglob

TRAVIS_BUILD_STEP="$1"

if [ "$TRAVIS_BUILD_STEP" == "install" ]; then
    sudo apt-get update -q
    sudo apt-get install -y devscripts cdbs osc

    if test "$encrypted_585e03da75ed_key" -a "$encrypted_585e03da75ed_iv"; then
        openssl aes-256-cbc -K $encrypted_585e03da75ed_key -iv $encrypted_585e03da75ed_iv -in linux/debian/signing-key.txt.enc -d | gpg --import
        echo "DEBUILD_DPKG_BUILDPACKAGE_OPTS='-k7D14AA7B'" >> ~/.devscripts

        openssl aes-256-cbc -K $encrypted_585e03da75ed_key -iv $encrypted_585e03da75ed_iv -in linux/debian/oscrc.enc -out ~/.oscrc -d
    elif test "$encrypted_8da7a4416c7a_key" -a "$encrypted_8da7a4416c7a_iv"; then
        openssl aes-256-cbc -K $encrypted_8da7a4416c7a_key -iv $encrypted_8da7a4416c7a_iv -in linux/debian/oscrc.enc -out ~/.oscrc -d
        PPA=ppa:ivaradi/nextcloud-client-exp
    fi

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

    cd ..

    echo "$kind" > kind

    if test "$kind" = "beta"; then
        repo=client-beta
    else
        repo=client
    fi

    origsourceopt=""
    #if ! wget http://ppa.launchpad.net/ivaradi/nextcloud-client-exp/ubuntu/pool/main/n/nextcloud-client/nextcloud-client_${basever}.orig.tar.bz2; then
    if ! wget http://ppa.launchpad.net/nextcloud-devs/${repo}/ubuntu/pool/main/n/nextcloud-client/nextcloud-client_${basever}.orig.tar.bz2; then
        mv client_theming nextcloud-client_${basever}
        tar cjf nextcloud-client_${basever}.orig.tar.bz2 --exclude .git nextcloud-client_${basever}
        mv nextcloud-client_${basever} client_theming
        origsourceopt="-sa"
    fi
fi
