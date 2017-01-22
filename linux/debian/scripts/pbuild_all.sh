#!/bin/bash

set -e -u

scriptdir=`dirname $0`
scriptdir=`cd "${scriptdir}" && pwd`

. "${scriptdir}/config.sh"

distribution="${1}"
shift

pushd /
"${scriptdir}/build_all.sh" "${distribution}" -S "$@"

"${scriptdir}/pbuilder_all.sh" "${distribution}" "$@"
popd
