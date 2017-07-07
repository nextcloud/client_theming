#! /bin/bash

export SUDO_UID=${SUDO_UID:-1000}
export SUDO_GID=${SUDO_GID:-1000}

export APP=Nextcloud
export LOWERAPP=${APP,,}
export ARCH=x86_64
export VERSION=2.3.2-beta

#Set Qt-5.8
export QT_BASE_DIR=/opt/qt58
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

#QtKeyChain 0.8.0
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
# No need to add CMake stuff
rm -rf usr/lib/x86_64-linux-gnu/cmake/
rm -rf usr/mkspecs
# Don't bundle nextcloudcmd as we don't run it anyway
rm usr/bin/nextcloudcmd
# Don't bundle the explorer extentions as we can't do anything with them in the AppImage
rm -rf usr/share/caja-python/
rm -rf usr/share/nautilus-python/
rm -rf usr/share/nemo-python/

#Move qt5.8 libs to the right location
mv ./opt/qt58/lib/* ./usr/lib/
rm -rf ./opt/

#Move sync exlucde to right location
mv ./usr/etc/Nextcloud/sync-exclude.lst ./usr/bin/
rm -rf ./usr/etc

#desktop intergration
get_desktopintegration $LOWERAPP

#Generate the appimage
cd ..
wget -c https://github.com/probonopd/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage --appimage-extract

mkdir -p ../out/
GLIBC_NEEDED=$(glibc_needed)
APPIMAGE_FILENAME=${APP}-${VERSION}-${ARCH}.glibc$GLIBC_NEEDED.AppImage
APPIMAGE_PATH=../out/$APPIMAGE_FILENAME

./squashfs-root/AppRun -n -v $APP.AppDir $APPIMAGE_PATH

#move appimage
chown $SUDO_UID:$SUDO_GID ../out/*.AppImage
mkdir -p /home/client/out
mv ../out/*.AppImage /home/client/out/
