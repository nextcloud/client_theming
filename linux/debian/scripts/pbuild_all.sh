#!/bin/bash

set -e -u

scriptdir=`dirname $0`

. "${scriptdir}/config.sh"

distribution="${1}"
shift

"${scriptdir}/build_all.sh" "${distribution}" --build=source "$@"

"${scriptdir}/pbuilder_all.sh" "${distribution}" "$@"
