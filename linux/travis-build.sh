#!/bin/bash
# Copyright (C) 2017 Marco Trevisan

set -xe

TRAVIS_BUILD_STEP="$1"
DOCKER_BUILDER_NAME='builder'

if [ -z "$TRAVIS_BUILD_STEP" ]; then
    echo "No travis build step defined"
    exit 0
fi

function docker_exec() {
    docker exec -i $DOCKER_BUILDER_NAME $*
}

if [ "$BUILD_TYPE" == "appimage" ]; then
    if [ "$TRAVIS_BUILD_STEP" == "script" ]; then
        linux/build.sh
    fi
elif [ "$BUILD_TYPE" == "snap" ]; then
    if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
        if [ "$SNAP_PRIME_ON_PULL_REQUEST" != "true" ]; then
            echo '$SNAP_PRIME_ON_PULL_REQUEST is not set to true, thus we skip this now'
            exit 0
        fi
    fi

    if [ "$TRAVIS_BUILD_STEP" == "before_install" ]; then
        if [ -n "$ARCH" ]; then DOCKER_IMAGE="$ARCH/$DOCKER_IMAGE"; fi
        docker run --name $DOCKER_BUILDER_NAME -e LANG=C.UTF-8 \
		   -v $PWD:$PWD -w $PWD/$(dirname $0) -td $DOCKER_IMAGE
    elif [ "$TRAVIS_BUILD_STEP" == "install" ]; then
        docker_exec apt-get update -q
        docker_exec apt-get install -y snapcraft
    elif [ "$TRAVIS_BUILD_STEP" == "script" ]; then
        snapcraft_action=''
        if [ -z "$TRAVIS_TAG" ] || [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
            snapcraft_action='prime'
        fi

        docker_exec snapcraft $snapcraft_action
    elif [ "$TRAVIS_BUILD_STEP" == "snap-deploy" ]; then
        set +x
        openssl aes-256-cbc -K $SNAPCRAFT_CONFIG_KEY \
            -iv $SNAPCRAFT_CONFIG_IV \
            -in $PWD/$(dirname $0)/snap/.snapcraft/travis_snapcraft.cfg \
            -out $PWD/$(dirname $0)/snap/.snapcraft/snapcraft.cfg -d
        set -x

        ls *.snap &> /dev/null || docker_exec snapcraft
        docker_exec snapcraft push *.snap --release edge
    fi
else
    echo 'No $BUILD_TYPE defined'
    exit 1
fi
