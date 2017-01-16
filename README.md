# nextcloud desktop client [![Build Status](https://travis-ci.org/nextcloud/client_theming.svg?branch=master)](https://travis-ci.org/nextcloud/client_theming) 
:computer: theme and build instructions for the nextcloud desktop client

Based on https://github.com/owncloud/client/blob/master/doc/building.rst

## Getting repository ready

Run:
```bash
git submodule update --init --recursive
```

## Building on Linux

Run:

```bash
mkdir build-linux
cd build-linux
cmake -D OEM_THEME_DIR=$(realpath `pwd`/../nextcloudtheme)  ../client
make
make install
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

Because the desktop client comes with a lot of custom patches you have to download the Qt 5.4.0 source and then apply all of them.

In addition to below patches you also need to apply https://codereview.qt-project.org/#/c/121545/

```bash
cd /tmp/
wget http://download.qt.io/official_releases/qt/5.4/5.4.0/single/qt-everywhere-opensource-src-5.4.0.tar.gz
tar -xf qt-everywhere-opensource-src-5.4.0.tar.gz
cd /tmp/qt-everywhere-opensource-src-5.4.0/qtbase
git apply --reject /Users/builder/client/admin/qt/patches/0001-Fix-crash-on-Mac-OS-if-PAC-URL-contains-non-URL-lega.patch
git apply --reject /Users/builder/client/admin/qt/patches/0002-Fix-possible-crash-when-passing-an-invalid-PAC-URL.patch
git apply --reject /Users/builder/client/admin/qt/patches/0003-Fix-crash-if-PAC-script-retrieval-returns-a-null-CFD.patch
git apply --reject /Users/builder/client/admin/qt/patches/0004-Cocoa-Fix-systray-SVG-icons.patch
git apply --reject /Users/builder/client/admin/qt/patches/0005-OSX-Fix-disapearing-tray-icon.patch
git apply --reject /Users/builder/client/admin/qt/patches/0006-Fix-force-debug-info-with-macx-clang_NOUPSTREAM.patch
git apply --reject /Users/builder/client/admin/qt/patches/0007-QNAM-Fix-upload-corruptions-when-server-closes-conne.patch
git apply --reject /Users/builder/client/admin/qt/patches/0007-X-Network-Fix-up-previous-corruption-patch.patch
git apply --reject /Users/builder/client/admin/qt/patches/0008-QNAM-Fix-reply-deadlocks-on-server-closing-connectio.patch
git apply --reject /Users/builder/client/admin/qt/patches/0009-QNAM-Assign-proper-channel-before-sslErrors-emission.patch
git apply --reject /Users/builder/client/admin/qt/patches/0010-Don-t-let-closed-http-sockets-pass-as-valid-connecti.patch
git apply --reject /Users/builder/client/admin/qt/patches/0011-Make-sure-to-report-correct-NetworkAccessibility.patch
git apply --reject /Users/builder/client/admin/qt/patches/0012-Make-sure-networkAccessibilityChanged-is-emitted.patch
git apply --reject /Users/builder/client/admin/qt/patches/0013-Make-UnknownAccessibility-not-block-requests.patch
git apply --reject /Users/builder/client/admin/qt/patches/0015-Remove-legacy-platform-code-in-QSslSocket-for-OS-X-1.patch
git apply --reject /Users/builder/client/admin/qt/patches/0016-QSslSocket-evaluate-CAs-in-all-keychain-categories.patch
git apply --reject /Users/builder/client/admin/qt/patches/0017-Win32-Re-init-system-proxy-if-internet-settings-chan.patch
git apply --reject /Users/builder/client/admin/qt/patches/0018-Windows-Do-not-crash-if-SSL-context-is-gone-after-ro.patch
git apply --reject /Users/builder/client/admin/qt/patches/0019-Ensure-system-tray-icon-is-prepared-even-when-menu-bar.patch
cd ..
./configure -sdk macosx10.9
make -j7
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

### Building the binary

```bash
docker run -v "$PWD:/home/user/" nextcloud-client-win32:2.2.2 /home/user/win/build.sh $(id -u)
```

## Building a release

When we build releases there are two additional cmake parameters to consider:

* `-DMIRALL_VERSION_SUFFIX=<STRING>`: for a generic suffix name such as `beta` or `rc1`
* `-DMIRALL_VERSION_BUILD=<INT>`: an internal build number. Should be strickly increasing. This allows update detection from `rc` to `final`

Note that this had mostly usage on Windows and OS X. On linux the package manager will take care of all this.
