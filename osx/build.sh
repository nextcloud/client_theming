#!/bin/bash
export PATH=/usr/local/Qt-5.9.2/bin/:$PATH
export OPENSSL_ROOT_DIR=$(brew --prefix openssl)

# Cleanup
cd ~
sudo rm -rf build-mac
sudo rm -rf client
sudo rm -rf install

# Clone the desktop client code
git clone --recursive https://github.com/owncloud/client.git
cd client
git checkout v2.3.3
git submodule update --recursive

# Build qtkeychain
cd ~/client/src/3rdparty/
git clone https://github.com/frankosterfeld/qtkeychain.git
cd qtkeychain
git checkout v0.8.0
cmake -DCMAKE_OSX_SYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk" -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 -DCMAKE_INSTALL_PREFIX=/Users/builder/install -DCMAKE_PREFIX_PATH=/Users/builder/Qt/5.9/clang_64 .
sudo make -j1 install

# Build the client
cd ~
cp client_theming/osx/dsa_pub.pem client/admin/osx/sparkle/
rm -rf build-mac
mkdir build-mac
cd build-mac
cmake -DCMAKE_OSX_SYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk" -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 -DCMAKE_INSTALL_PREFIX=/Users/builder/install -DCMAKE_PREFIX_PATH=/Users/builder/Qt/5.9/clang_64 -D SPARKLE_INCLUDE_DIR=/Users/builder/Library/Frameworks/Sparkle.framework/ -D SPARKLE_LIBRARY=/Users/builder/Library/Frameworks/Sparkle.framework/ -D OEM_THEME_DIR=/Users/builder/client_theming/nextcloudtheme -DWITH_CRASHREPORTER=ON -DNO_SHIBBOLETH=1 -DMIRALL_VERSION_BUILD=1 ../client
make -j2
sudo make -j1 install
# The magic string here is SHA1 hash of your Developer ID Application certificate
sudo ~/client/admin/osx/sign_app.sh ~/install/nextcloud.app 74FB2413760D6407588B69F499F13514A86AE
# The magic string here is SHA1 hash of your Developer ID Installer certificate
sudo ~/build-mac/admin/osx/create_mac.sh ../install/ . 1B8B3FD4A0ADCC5BF4385FA1A50F4547DE73C95E

# Generate a sparkle signature for the tbz
openssl dgst -sha1 -binary < ~/install/*.tbz | openssl dgst -dss1 -sign ~/dsa_priv.pem | openssl enc -base64 > ~/sig.txt
sudo mv ~/sig.txt ~/install/signature.txt
