#!/bin/bash

set -xe

TRAVIS_BUILD_STEP="$1"

if [ "$TRAVIS_BUILD_STEP" == "install" ]; then
    sudo apt-get update -q
    sudo apt-get install -y devscripts cdbs

    openssl aes-256-cbc -K $encrypted_8da7a4416c7a_key -iv $encrypted_8da7a4416c7a_iv -in linux/debian/signing-key.txt.enc -d | gpg --import
    echo "DEBUILD_DPKG_BUILDPACKAGE_OPTS='-k7D14AA7B'" >> ~/.devscripts

elif [ "$TRAVIS_BUILD_STEP" == "script" ]; then
    pwd
    ls -al
    git log
    basever=`linux/debian/scripts/git2changelog.py /tmp/tmpchangelog stable`

    cd ..
    origsourceopt=""
    if ! wget http://ppa.launchpad.net/ivaradi/nextcloud-client-exp/ubuntu/pool/main/n/nextcloud-client/nextcloud-client_${basever}.orig.tar.bz2; then
    #if ! wget http://ppa.launchpad.net/nextcloud-devs/client/ubuntu/pool/main/n/nextcloud-client/nextcloud-client_${basever}.orig.tar.bz2; then
        mv client_theming nextcloud-client_${basever}
        tar cjf nextcloud-client_${basever}.orig.tar.bz2 --exclude .git nextcloud-client_${basever}
        mv nextcloud-client_${basever} client_theming
        origsourceopt="-sa"
    fi

    for distribution in trusty xenial yakkety zesty; do
        rm -rf nextcloud-client_${basever}
        cp -a client_theming nextcloud-client_${basever}

        cd nextcloud-client_${basever}

        cp -a linux/debian/nextcloud-client/debian .
        if test -d linux/debian/nextcloud-client/debian.${distribution}; then
            cp -a linux/debian/nextcloud-client/debian.${distribution} debian
        fi

        linux/debian/scripts/git2changelog.py /tmp/tmpchangelog ${distribution}
        cp /tmp/tmpchangelog debian/changelog
        if test -f linux/debian/nextcloud-client/debian.${distribution}/changelog; then
            cat linux/debian/nextcloud-client/debian.${distribution}/changelog >> debian/changelog
        else
            cat linux/debian/nextcloud-client/debian/changelog >> debian/changelog
        fi

        EDITOR=true dpkg-source --commit . local-changes

        debuild -S ${origsourceopt}

        cd ..
    done

elif [ "$TRAVIS_BUILD_STEP" == "snap_store_deploy" ]; then
    pwd

    for changes in nextcloud-client*_source.changes; do
        dput ppa:ivaradi/nextcloud-client-exp $changes > /dev/null
    done
fi
