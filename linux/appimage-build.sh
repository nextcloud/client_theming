#!/bin/bash

########################################################################
# Build as per the instructions, but install in /app rather than /usr
########################################################################

sudo sh -c "echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_14.04/ /' >> /etc/apt/sources.list.d/owncloud-client.list"
sudo sh -c "echo 'deb-src http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_14.04/ /' >> /etc/apt/sources.list.d/owncloud-client.list"
wget http://download.opensuse.org/repositories/isv:ownCloud:desktop/Ubuntu_14.04/Release.key
sudo apt-key add - < Release.key
sudo apt-get update
sudo apt-get -y build-dep owncloud-client

git submodule update --init --recursive
mkdir build-linux
cd build-linux
cmake -D CMAKE_INSTALL_PREFIX=/usr -D OEM_THEME_DIR=`pwd`/../nextcloudtheme ../client
make
find .
sudo make install DESTDIR=/app
find /app

########################################################################
# Package the binaries built on Travis-CI as an AppImage
# By Simon Peter 2016
# For more information, see http://appimage.org/
########################################################################

export ARCH=$(arch)

APP=Nextcloud
LOWERAPP=${APP,,}

GIT_REV=$(git rev-parse --short HEAD)
echo $GIT_REV

mkdir -p $HOME/$APP/$APP.AppDir/usr/

cd $HOME/$APP/

wget -q https://github.com/probonopd/AppImages/raw/master/functions.sh -O ./functions.sh
. ./functions.sh

cd $APP.AppDir

sudo chown -R $USER /app/
sed -i -e 's|/app|././|g' /app/bin/nextcloud

cp -r /app/* ./usr/

########################################################################
# Copy desktop and icon file to AppDir for AppRun to pick them up
########################################################################

get_apprun

cp /app/share/applications/nextcloud.desktop .
cp /app/share/icons/hicolor/256x256/apps/Nextcloud.png nextcloud.png

########################################################################
# Copy in the dependencies that cannot be assumed to be available
# on all target systems
########################################################################

# FIXME: How to find out which subset of plugins is really needed?
mkdir -p ./usr/lib/qt4/plugins/
cp -r /usr/lib/x86_64-linux-gnu/qt4/plugins/* ./usr/lib/qt4/plugins/

copy_deps

########################################################################
# Delete stuff that should not go into the AppImage
########################################################################

# Delete dangerous libraries; see
# https://github.com/probonopd/AppImages/blob/master/excludelist
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

########################################################################
# desktopintegration asks the user on first run to install a menu item
########################################################################

get_desktopintegration $LOWERAPP

########################################################################
# Determine the version of the app
########################################################################

VERSION=git.$GIT_REV

########################################################################
# Patch away absolute paths; it would be nice if they were relative
########################################################################

# patch_usr
# Possibly need to patch additional hardcoded paths away, replace
# "/usr" with "././" which means "usr/ in the AppDir"

########################################################################
# AppDir complete
# Now packaging it as an AppImage
########################################################################

cd .. # Go out of AppImage

mkdir -p ../out/
generate_type2_appimage

########################################################################
# Upload the AppDir
########################################################################

if [ -n "$GITHUB_TOKEN" ]; then
  wget -c https://github.com/probonopd/uploadtool/raw/master/upload.sh
  bash upload.sh ../out/*
else
  transfer ../out/*
  echo "AppImage has been uploaded to the URL above; use something like GitHub Releases for permanent storage"
fi
