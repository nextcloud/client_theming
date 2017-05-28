#/bin/bash

#Get Qt-5.8
source /opt/qt58/bin/qt58-env.sh

#QtKeyChain
cd
git clone https://github.com/frankosterfeld/qtkeychain.git
cd qtkeychain
git checkout v0.8.0
mkdir build
cd build
cmake -D CMAKE_INSTALL_PREFIX=/app ../
make -j4
make install

#Build client
cd
mkdir build-client
cd build-client
cmake -D CMAKE_INSTALL_PREFIX=/app \
    -D NO_SHIBBOLETH=1 \
    -D OEM_THEME_DIR=/home/client/nextcloudtheme \
    -DMIRALL_VERSION_SUFFIX=beta \
    -DMIRALL_VERSION_BUILD=14 \
    /home/client/client
make -j4
make install

#Set info
ARCH=$(arch)
APP=Nextcloud
LOWERAPP=${APP,,}
VERSION=2.3.2-beta

#Create skeleton
mkdir -p $HOME/$APP/$APP.AppDir/usr/
cd $HOME/$APP/

#Fetch appimage functions
wget -q https://github.com/probonopd/AppImages/raw/master/functions.sh -O ./functions.sh
. ./functions.sh

cd $APP.AppDir

#clean binary
sed -i -e 's|/app|././|g' /app/bin/nextcloud

# Copy installed stuff
cp -r /app/* ./usr/

get_apprun

cp /app/share/applications/nextcloud.desktop .
cp /app/share/icons/hicolor/256x256/apps/Nextcloud.png nextcloud.png

#Copy qt plugins
mkdir -p ./usr/lib/qt5/plugis
cp -r /opt/qt58/plugins ./usr/lib/qt5/plugins

#Copy dependencies
copy_deps

delete_blacklisted

# We don't bundle the developer stuff
rm -rf usr/include || true
rm -rf usr/lib/cmake || true
rm -rf usr/lib/pkgconfig || true
find . -name '*.la' | xargs -i rm {}
strip usr/bin/* usr/lib/* || true
rm -rf app/ || true
# Copy, since libssl must be in sync with libcrypto
cp /lib/x86_64-linux-gnu/libssl.so.1.0.0 usr/lib/


#Move qt5.8 libs to the right location
mv ./opt/qt58/lib/* ./usr/lib/
rm -rf ./opt/

#Move sync exlucde to right location
mv ./usr/etc/Nextcloud/sync-exclude.lst ./usr/bin/

#desktop intergration
get_desktopintegration $LOWERAPP

#Generate the appimage
cd ..
mkdir -p ../out/
generate_type2_appimage

#move appimag
mv ../out/ /home/client/
