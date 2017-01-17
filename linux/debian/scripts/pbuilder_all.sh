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

dscversion=`echo ${QTKEYCHAIN_FULL_VERSION} | sed "s:@DISTRIBUTION@:${distribution}:g"`
pbuilder-dist "${distribution}" build --othermirror "${OTHERMIRROR}" "$@" "${BUILDAREA}/qtkeychain_${dscversion}.dsc"
cp "${resultdir}/"*.deb "${PBUILDER_DEPS}"

dscversion=`echo ${NEXTCLOUD_CLIENT_FULL_VERSION} | sed "s:@DISTRIBUTION@:${distribution}:g"`
pbuilder-dist "${distribution}" build --othermirror "${OTHERMIRROR}" "$@" "${BUILDAREA}/nextcloud-client_${dscversion}.dsc"
