#! /bin/bash

set -e # Exit on errors so that the Travis CI status indicator works

export APP=Nextcloud
export VERSION=2.3.2-beta

sudo sh -c "echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_14.04/ /' >> /etc/apt/sources.list.d/owncloud-client.list"
sudo sh -c "echo 'deb-src http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_14.04/ /' >> /etc/apt/sources.list.d/owncloud-client.list"
wget http://download.opensuse.org/repositories/isv:ownCloud:desktop/Ubuntu_14.04/Release.key
sudo apt-key add - < Release.key
sudo apt-get update
sudo apt-get -y build-dep owncloud-client

#QtKeyChain 0.8.0
#git clone https://github.com/frankosterfeld/qtkeychain.git
#cd qtkeychain
#git checkout v0.8.0
#mkdir build
#cd build
#cmake .. -DCMAKE_INSTALL_PREFIX=/usr
#make -j4
#make DESTDIR=$(readlink -f $HOME/$APP/$APP.AppDir) install

git submodule update --init --recursive
mkdir build-linux
cd build-linux
cmake -D CMAKE_INSTALL_PREFIX=/usr -D OEM_THEME_DIR=`pwd`/../nextcloudtheme ../client
make
make DESTDIR=$(readlink -f $APP.AppDir) install

cd $APP.AppDir

# Why on earth...
mv ./usr/lib/x86_64-linux-gnu/nextcloud/* ./usr/lib/x86_64-linux-gnu/ ; rm -rf ./usr/lib/x86_64-linux-gnu/nextcloud

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
mv ./etc/Nextcloud/sync-exclude.lst ./usr/bin/
rm -rf ./etc

sed -i -e 's|Icon=nextcloud|Icon=Nextcloud|g' usr/share/applications/nextcloud.desktop # Bug in desktop file?
cp ./usr/share/icons/hicolor/512x512/apps/Nextcloud.png . # Workaround for linuxeployqt bug, FIXME

find .

cd ..

# Use linuxdeployqt to deploy
wget -c "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage" 
chmod a+x linuxdeployqt*.AppImage
./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract
unset QTDIR; unset QT_PLUGIN_PATH ; unset LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$APP.AppDir/usr/lib/x86_64-linux-gnu/

./squashfs-root/AppRun $APP.AppDir/usr/share/applications/nextcloud.desktop -bundle-non-qt-libs

# Why on earth part two...
mv $APP.AppDir/usr/lib/x86_64-linux-gnu/* $APP.AppDir/usr/lib/
find $APP.AppDir/usr/lib/libnextcloudsync.so* -type f -exec patchelf  --set-rpath '$ORIGIN/' {} \;

./squashfs-root/AppRun $APP.AppDir/usr/share/applications/nextcloud.desktop -appimage

ls *.AppImage

# mv ./Nextcloud*.AppImage /home/client/out/

########################################################################
# Upload the AppDir
########################################################################

if [ "false" == "$TRAVIS_PULL_REQUEST" ]; then
  wget -c https://github.com/probonopd/uploadtool/raw/master/upload.sh
  bash upload.sh $(readlink -f ./Nextcloud*.AppImage)
else
  curl --upload-file $(readlink -f ./Nextcloud*.AppImage) https://transfer.sh/Nextcloud-$VERSION-x86_64.AppImage
  echo "AppImage has been uploaded to the URL above"
fi
