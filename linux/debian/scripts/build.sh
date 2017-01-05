#!/bin/bash

set -e -u

scriptdir=`dirname $0`

. "${scriptdir}/config.sh"

package="${1}"
tag="${2}"
version="${3}"
distribution="${4}"
shift 4

"${scriptdir}/create_debdir.sh" "${package}" "${tag}" "${version}" "${distribution}"

(cd "${BUILDAREA}/${package}_${version}"; debuild "$@")
