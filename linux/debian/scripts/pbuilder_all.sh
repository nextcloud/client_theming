#!/bin/bash

set -e -u

scriptdir=`dirname $0`

. "${scriptdir}/config.sh"

distribution="${1}"
shift

resultdir="${PBUILDER_ROOT}/${distribution}_result"

rm -f "${PBUILDER_DEPS}/"*.deb
echo -n > "${PBUILDER_DEPS}/Packages"
rm -f "${resultdir}/"*

source "${HOME}/.pbuilderrc"

pbuilder-dist "${distribution}" build --othermirror "${OTHERMIRROR}" "$@" "${BUILDAREA}/qtkeychain_${QTKEYCHAIN_FULL_VERSION}.dsc"
cp "${resultdir}/"*.deb "${PBUILDER_DEPS}"

pbuilder-dist "${distribution}" build --othermirror "${OTHERMIRROR}" "$@" "${BUILDAREA}/nextcloud-client_${NEXTCLOUD_CLIENT_FULL_VERSION}.dsc"
