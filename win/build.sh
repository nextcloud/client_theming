#!/bin/bash

useradd user -u ${1:-1000}
su - user << EOF
  cd /home/user/
  rm -rf build-win32
  mkdir build-win32
  cd build-win32
  ../client/admin/win/download_runtimes.sh
  cmake -DCMAKE_TOOLCHAIN_FILE=../client/admin/win/Toolchain-mingw32-openSUSE.cmake\
  -DWITH_CRASHREPORTER=ON \
  -DOEM_THEME_DIR=/home/user/nextcloudtheme \
  ../client
  make -j4
  make package
  ctest .
EOF
