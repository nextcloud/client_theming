# Nextcloud desktop client
[![Build Status](https://travis-ci.org/nextcloud/client_theming.svg?branch=master)](https://travis-ci.org/nextcloud/client_theming)

**Theme and build instructions for the [Nextcloud](https://nextcloud.com) desktop client.**

Based on https://github.com/owncloud/client/blob/master/doc/building.rst

## Installing on Ubuntu
```bash
sudo add-apt-repository ppa:nextcloud-devs/client
sudo apt-get update
sudo apt-get install nextcloud-client
```
Launchpad: https://launchpad.net/~nextcloud-devs/+archive/ubuntu/client

### Beta packages

```bash
sudo add-apt-repository ppa:nextcloud-devs/client-beta
sudo apt-get update
sudo apt-get install nextcloud-client
```
Launchpad: https://launchpad.net/~nextcloud-devs/+archive/ubuntu/client-beta

If you always want the latest versions (including the betas), add both
repositories. If you want only the stable version, add the non-beta
repository only.

## Installing on Debian

You need to add to `sources.list` or a separate source list file one of the source lines below corresponding to your Debian version:

```
deb http://download.opensuse.org/repositories/home:/ivaradi/Debian_9.0_update/ /
deb http://download.opensuse.org/repositories/home:/ivaradi/Debian_9.0/ /
deb http://download.opensuse.org/repositories/home:/ivaradi/Debian_8.0/ /
deb http://download.opensuse.org/repositories/home:/ivaradi/Debian_7.0/ /
```

Before installing, you also need to add the respository's key to the list of trusted APT keys with a command line:

```
wget -q -O - <repository URL>/Release.key | apt-key add -y
```

For example (as root):

```bash
echo 'deb http://download.opensuse.org/repositories/home:/ivaradi/Debian_9.0/ /' > /etc/apt/sources.list.d/nextcloud-client.list
wget -q -O - http://download.opensuse.org/repositories/home:/ivaradi/Debian_9.0/Release.key | apt-key add -
apt-get update
apt-get install nextcloud-client
```

### Beta packages

Beta packages are also available:

```
deb http://download.opensuse.org/repositories/home:/ivaradi:/beta/Debian_9.0_update/ /
deb http://download.opensuse.org/repositories/home:/ivaradi:/beta/Debian_9.0/ /
deb http://download.opensuse.org/repositories/home:/ivaradi:/beta/Debian_8.0/ /
deb http://download.opensuse.org/repositories/home:/ivaradi:/beta/Debian_7.0/ /
```

If you always want the latest versions (including the betas), add both the normal and the beta repositories. If you want only the stable version, add the non-beta repository only.

## Snaps

### Building the snap
```bash
cd linux
snapcraft
```

### Installing via Snap package ([supported distributions](https://snapcraft.io/docs/core/install))
Download the [snap package](https://github.com/nextcloud/client_theming/releases/tag/continuous) for your architecture
```bash
sudo snap install --dangerous nextcloud-client_*.snap
```
Installing a snap is very quick. Snaps are secure. They are isolated with all of their dependencies. Snaps also auto update when a new version is released.
The snap is confined, thus the synced folders will be by default in `~/snap/<version>/`, the client can access to the actual home, but not to the `.dotted` files, use symlinks if you need to.

## Building on Linux

### Getting repository ready

Run:
```bash
git submodule update --init --recursive
```

Run:

```bash
# If building on Ubuntu
sudo apt-get install libsqlite3-dev qt5-default libqt5webkit5-dev qt5keychain-dev libssl-dev

# All distributions
mkdir build-linux
cd build-linux
cmake -D OEM_THEME_DIR=$(realpath ../nextcloudtheme)  ../client
make
sudo make install
```

## Building on Debian

Install required packages.

    sudo apt-get install git libsqlite3-dev qt5-default libqt5webkit5-dev qt5keychain-dev cmake build-essential libowncloudsync0

If you are using Debian 9 install libssl1.0-dev

    sudo apt-get install libssl1.0-dev

If you are using Debian 8 install libssl-dev

    sudo apt-get install libssl-dev

Then:

```bash
git clone https://github.com/nextcloud/client_theming.git
cd client_theming
git submodule update --init --recursive
mkdir build-linux
cd build-linux
cmake -D OEM_THEME_DIR=$(realpath ../nextcloudtheme) -DCMAKE_INSTALL_PREFIX=/usr  ../client
make
sudo make install
```

## Building on OSX

*Attention:* When building make sure to use an old Core 2 Duo build machine running OS X 10.10. Otherwise the resulting binary won't work properly for users of an older device. Have at least 180 GB free disk space when compiling Qt. Make sure your user is named "builder".

### Install dependencies

1. Install [HomeBrew](http://brew.sh/)
2. `brew install openssl wget cmake`
3. `wget https://github.com/sparkle-project/Sparkle/releases/download/1.14.0/Sparkle-1.14.0.tar.bz2`
4. `tar -xf Sparkle-1.14.0.tar.bz2`
5. `mv Sparkle.framework ~/Library/Frameworks/`
6. Install XCode 6.4 from http://adcdownload.apple.com/Developer_Tools/Xcode_6.4/Xcode_6.4.dmg
7. sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
8. Generate Sparkle keys: `./bin/generate_keys`. Keep those, if you loose it you won't be able to deploy updates anymore.
9. Store the keys in `osx/`. Make sure to not make the `dsa_priv.pem` publicly available.
10. Install http://s.sudre.free.fr/Software/Packages/about.html

### Compile Qt

Because the desktop client comes with some custom patches you have to download the Qt 5.6.2 source and then apply all of them. Make sure to adjust <client> with the login to the cloned client repository.

```bash
cd /tmp/
wget http://download.qt.io/official_releases/qt/5.6/5.6.2/single/qt-everywhere-opensource-src-5.6.2.tar.gz
tar -xf qt-everywhere-opensource-src-5.6.2.tar.gz
cd /tmp/qt-everywhere-opensource-src-5.6.2/qtbase
git apply <client>/admin/qt/patches/qtbase/*.patch
cd ..
./configure -sdk macosx10.9 -openssl -openssl-linked
make -j2
sudo make -j1 install
```

### Build the client

```bash
sh osx/build.sh
```

## Building on Windows

### Building the docker image

The docker image contains the toolchain to build the windows binary.
Build it:

```bash
docker build -t nextcloud-client-win32:<version> client/admin/win/docker/
```

_Note: if you encounter an error at this step that the MinGW repository was not found, apply the patch at_ `win/opensuse-mingw-repo-location.patch` _and try again:_

```bash
cd client
patch -p1 < ../win/opensuse-mingw-repo-location.patch
cd ..
```

### Building the binary

```bash
docker run -v "$PWD:/home/user/" nextcloud-client-win32:2.2.2 /home/user/win/build.sh $(id -u)
```

## Building a release

When we build releases there are two additional cmake parameters to consider:

* `-DMIRALL_VERSION_SUFFIX=<STRING>`: for a generic suffix name such as `beta` or `rc1`
* `-DMIRALL_VERSION_BUILD=<INT>`: an internal build number. Should be strictly increasing. This allows update detection from `rc` to `final`

Note that this had mostly usage on Windows and OS X. On Linux the package manager will take care of all this.
