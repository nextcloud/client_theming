#! /bin/bash

set -e # Exit on errors so that the Travis CI status indicator works

export APP=Nextcloud
export VERSION=2.3.2-beta

#Set Qt-5.8
export QT_BASE_DIR=/opt/qt58
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

#QtKeyChain 0.8.0
git clone https://github.com/frankosterfeld/qtkeychain.git
cd qtkeychain
git checkout v0.8.0
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make -j4
make DESTDIR=$(readlink -f $HOME/$APP/$APP.AppDir) install

#Build client
mkdir build-client
cd build-client
cmake -DCMAKE_INSTALL_PREFIX=/usr \
    -D NO_SHIBBOLETH=1 \
    -D OEM_THEME_DIR=/home/client/nextcloudtheme \
    -DMIRALL_VERSION_SUFFIX=beta \
    -DMIRALL_VERSION_BUILD=14 \
    /home/client/client
make -j4
make DESTDIR=$(readlink -f $HOME/$APP/$APP.AppDir) install

cd $APP.AppDir

# We don't bundle the developer stuff
rm -rf usr/include || true
rm -rf usr/lib/cmake || true
rm -rf usr/lib/pkgconfig || true
find . -name '*.la' | xargs -i rm {}
rm -rf usr/lib/x86_64-linux-gnu/cmake/
rm -rf usr/mkspecs

# Don't bundle nextcloudcmd as we don't run it anyway
rm usr/bin/nextcloudcmd

# Don't bundle the explorer extentions as we can't do anything with them in the AppImage
rm -rf usr/share/caja-python/
rm -rf usr/share/nautilus-python/
rm -rf usr/share/nemo-python/

# Move sync exlucde to right location
mv ./usr/etc/Nextcloud/sync-exclude.lst ./usr/bin/
rm -rf ./usr/etc

cd ..

# Use linuxdeployqt to deploy
wget -c "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage" 
chmod a+x linuxdeployqt*.AppImage
./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract
unset QTDIR; unset QT_PLUGIN_PATH ; unset LD_LIBRARY_PATH
  
./squashfs-root/AppRun $(readlink -f $HOME/$APP/$APP.AppDir)/usr/share/applications/nextcloud.desktop -bundle-non-qt-libs
./squashfs-root/AppRun $(readlink -f $HOME/$APP/$APP.AppDir)/usr/share/applications/nextcloud.desktop -appimage

ls *.AppImage

mv ./Nextcloud*.AppImage /home/client/out/
