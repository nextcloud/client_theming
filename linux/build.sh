#!/bin/bash

sudo sh -c "echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_14.04/ /' >> /etc/apt/sources.list.d/owncloud-client.list"
sudo sh -c "echo 'deb-src http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_14.04/ /' >> /etc/apt/sources.list.d/owncloud-client.list"
wget http://download.opensuse.org/repositories/isv:ownCloud:desktop/Ubuntu_14.04/Release.key
sudo apt-key add - < Release.key
sudo apt-get update
sudo apt-get -y build-dep owncloud-client

# sudo apt-get -y install debhelper dh-apparmor docutils-common doxygen intltool-debian libjs-sphinxdoc libjs-underscore libqtkeychain1 po-debconf python-docutils python-jinja2 python-markupsafe python-pygments python-roman python-sphinx qtkeychain-dev sphinx-common
  
git submodule update --init --recursive
mkdir build-linux
cd build-linux
cmake -D CMAKE_INSTALL_PREFIX=/app -D OEM_THEME_DIR=`pwd`/../nextcloudtheme ../client
make
find . 
sudo make install
find /app
exit 0
