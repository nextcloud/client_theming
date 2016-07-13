#! /bin/bash

git submodule update --init
cd client
git submodule update --init
cd ..
mkdir -p build
cd build
cmake -D OEM_THEME_DIR=`pwd`/../nextcloudtheme ../client
make
