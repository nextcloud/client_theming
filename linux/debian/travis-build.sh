#!/bin/bash

set -xe

TRAVIS_BUILD_STEP="$1"

PPA=ppa:nextcloud-devs/client

OBS_PROJECT=home:ivaradi
OBS_PACKAGE=nextcloud-client
OBS_SUBDIR="${OBS_PROJECT}/${OBS_PACKAGE}"

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

elif [ "$TRAVIS_BUILD_STEP" == "script" ]; then
    #pwd
    #ls -al
    #git log
    basever=`linux/debian/scripts/git2changelog.py /tmp/tmpchangelog stable`

    cd ..
    origsourceopt=""
    #if ! wget http://ppa.launchpad.net/ivaradi/nextcloud-client-exp/ubuntu/pool/main/n/nextcloud-client/nextcloud-client_${basever}.orig.tar.bz2; then
    if ! wget http://ppa.launchpad.net/nextcloud-devs/client/ubuntu/pool/main/n/nextcloud-client/nextcloud-client_${basever}.orig.tar.bz2; then
        mv client_theming nextcloud-client_${basever}
        tar cjf nextcloud-client_${basever}.orig.tar.bz2 --exclude .git nextcloud-client_${basever}
        mv nextcloud-client_${basever} client_theming
        origsourceopt="-sa"
    fi

    for distribution in trusty xenial yakkety zesty stable; do
        rm -rf nextcloud-client_${basever}
        cp -a client_theming nextcloud-client_${basever}

        cd nextcloud-client_${basever}

        cp -a linux/debian/nextcloud-client/debian .
        if test -d linux/debian/nextcloud-client/debian.${distribution}; then
            tar cf - -C linux/debian/nextcloud-client/debian.${distribution} . | tar xf - -C debian
        fi

        linux/debian/scripts/git2changelog.py /tmp/tmpchangelog ${distribution}
        cp /tmp/tmpchangelog debian/changelog
        if test -f linux/debian/nextcloud-client/debian.${distribution}/changelog; then
            cat linux/debian/nextcloud-client/debian.${distribution}/changelog >> debian/changelog
        else
            cat linux/debian/nextcloud-client/debian/changelog >> debian/changelog
        fi

        EDITOR=true dpkg-source --commit . local-changes

        if test "$encrypted_585e03da75ed_key" -a "$encrypted_585e03da75ed_iv"; then
            debuild -S ${origsourceopt}
        else
            debuild -S ${origsourceopt} -us -uc
        fi

        cd ..
    done

elif [ "$TRAVIS_BUILD_STEP" == "snap_store_deploy" ]; then
    cd ..

    if test "$encrypted_585e03da75ed_key" -a "$encrypted_585e03da75ed_iv"; then
        for changes in nextcloud-client*_source.changes; do
            dput $PPA $changes > /dev/null
        done
    fi

    mkdir osc
    cd osc
    osc co ${OBS_PROJECT} ${OBS_PACKAGE}
    osc delete ${OBS_SUBDIR}/*
    cp ../nextcloud-client*.orig.tar.* ${OBS_SUBDIR}/
    cp ../nextcloud-client_*[0-9.][0-9].dsc ${OBS_SUBDIR}/
    cp ../nextcloud-client_*[0-9.][0-9].debian.tar* ${OBS_SUBDIR}/
    cp ../nextcloud-client_*[0-9.][0-9]_source.changes ${OBS_SUBDIR}/
    osc add ${OBS_SUBDIR}/*

    cd ${OBS_SUBDIR}
    osc commit -m "Travis update"
fi
