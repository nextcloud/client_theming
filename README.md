# nextcloud desktop client
:computer: theme and build instructions for the nextcloud dekstop client

Based on https://github.com/owncloud/client/blob/master/doc/building.rst

## Getting repository ready

Run:
```bash
git submodule update --init
cd client
git submodule update --init
cd ...
```

## Building on Linux

Run:

```bash
mkdir build-linux
cd build-linux
cmake -D OEM_THEME_DIR=`pwd`/../nextcloudtheme ../client
make
make install
```

## Building on OSX

TODO

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
