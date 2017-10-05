#!/bin/bash
# Copyright (C) 2017 Marco Trevisan

set -xe

TRAVIS_BUILD_STEP="$1"
DOCKER_BUILDER_NAME='builder'
THIS_PATH=$(dirname $0)

if [ -z "$TRAVIS_BUILD_STEP" ]; then
    echo "No travis build step defined"
    exit 0
fi

function docker_exec() {
    docker exec -i $DOCKER_BUILDER_NAME $*
}

if [ "$BUILD_TYPE" == "appimage" ]; then
    if [ "$TRAVIS_BUILD_STEP" == "script" ]; then
        $THIS_PATH/appimage-build.sh
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
        docker run --name $DOCKER_BUILDER_NAME -e LANG=C.UTF-8 -e TERM \
                   -v $PWD:$PWD -w $PWD/$THIS_PATH -td $DOCKER_IMAGE
    elif [ "$TRAVIS_BUILD_STEP" == "install" ]; then
        docker_exec apt-get update -q
        docker_exec apt-get install -y snapcraft
    elif [ "$TRAVIS_BUILD_STEP" == "before_script" ]; then
        last_tag=$(git describe --tags --abbrev=0 | sed "s/^v\([0-9]\)/\1/")
        snap_version=$last_tag

        if [ -z "$TRAVIS_TAG" ]; then
            rev_commit=$(git rev-parse --short HEAD)
            snap_version=$last_tag+git${rev_commit}
        fi

        sed "s,^\(version:\)\([ ]*[0-9.a-z_-+]*\),\1 $snap_version," \
            -i $THIS_PATH/snap/snapcraft.yaml
        echo "Snap version is $snap_version"
    elif [ "$TRAVIS_BUILD_STEP" == "script" ]; then
        snapcraft_action=''
        if [ -z "$TRAVIS_TAG" ] || [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
            snapcraft_action='prime'
        fi

        docker_exec snapcraft $snapcraft_action
    elif [ "$TRAVIS_BUILD_STEP" == "after_success" ]; then
        if [ -n "$GITHUB_TOKEN" ]; then
            exec $0 snap_github_release
        else
            exec $0 snap_transfer_deploy
        fi
    elif [ "$TRAVIS_BUILD_STEP" == "snap_store_deploy" ]; then
        set +x
        openssl aes-256-cbc -K $SNAPCRAFT_CONFIG_KEY \
            -iv $SNAPCRAFT_CONFIG_IV \
            -in $THIS_PATH/snap/.snapcraft/travis_snapcraft.cfg \
            -out $THIS_PATH/snap/.snapcraft/snapcraft.cfg -d
        set -x

        ls $THIS_PATH/*.snap &> /dev/null || docker_exec snapcraft
        docker_exec snapcraft push *.snap --release edge
    elif [ "$TRAVIS_BUILD_STEP" == "snap_github_release" ]; then
        ls $THIS_PATH/*.snap &> /dev/null || docker_exec snapcraft
        snap=$(ls $THIS_PATH/*.snap -1 | head -n1)
        wget -c https://github.com/probonopd/uploadtool/raw/master/upload.sh
        chmod +x upload.sh
        exec ./upload.sh "$snap"
    elif [ "$TRAVIS_BUILD_STEP" == "snap_transfer_deploy" ]; then
        ls $THIS_PATH/*.snap &> /dev/null || docker_exec snapcraft
        snap=$(ls $THIS_PATH/*.snap -1 | head -n1)
        curl --progress-bar --upload-file "$snap" "https://transfer.sh/$(basename $snap)"
    fi
elif [ "$BUILD_TYPE" == "debian" ]; then
    linux/debian/travis-build.sh "$@"
elif [ "$BUILD_TYPE" == "win" ]; then
    win/travis-build.sh "$@"
else
    echo 'No $BUILD_TYPE defined'
    exit 1
fi
