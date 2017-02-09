#!/bin/bash

set -e -u

scriptdir=`dirname $0`
scriptdir=`cd "${scriptdir}" && pwd`

. "${scriptdir}/config.sh"

distribution="${1}"
shift

rm -rf "${BUILDAREA}"

pushd /

"${scriptdir}/build.sh" qtkeychain "${QTKEYCHAIN_TAG}" "${QTKEYCHAIN_VERSION}" "${distribution}" "$@"
"${scriptdir}/build.sh" nextcloud-client "${NEXTCLOUD_CLIENT_TAG}" "${NEXTCLOUD_CLIENT_VERSION}" "${distribution}" "$@"

popd
