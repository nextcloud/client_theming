#!/bin/bash
cd ~
cp client-theming/osx/dsa_pub.pem client/admin/osx/sparkle/
rm -rf build-mac
mkdir build-mac
cd build-mac
export PATH=/usr/local/Qt-5.4.0/bin/:$PATH
export OPENSSL_ROOT_DIR=$(brew --prefix openssl)
cmake -DCMAKE_OSX_SYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk" -DCMAKE_OSX_DEPLOYMENT_TARGET=10.8 -DCMAKE_INSTALL_PREFIX=/Users/lukasreschke/install -DCMAKE_PREFIX_PATH=/Users/lukasreschke/Qt/5.4/clang_64 -D SPARKLE_INCLUDE_DIR=/Users/lukasreschke/Library/Frameworks/ -D SPARKLE_LIBRARY=/Users/lukasreschke/Library/Frameworks/ -D OEM_THEME_DIR=/Users/lukasreschke/client-theming/nextcloudtheme -DWITH_CRASHREPORTER=ON ../client
make
make install
./admin/osx/create_mac.sh ../install/ .
