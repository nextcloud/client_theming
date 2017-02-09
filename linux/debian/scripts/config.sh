# The directory where the sources are found
SOURCES="${HOME}/sources/nextcloud"

# The directory into which the packages should be genereated
BUILDAREA="${SOURCES}/build-area"

# The directory containing the Git repositories
GITROOTS="${SOURCES}/git"

# The pbuilder root directory
PBUILDER_ROOT="${HOME}/pbuilder"

# The dependencies directory for pbuilder
PBUILDER_DEPS="${PBUILDER_ROOT}/deps"

# The version of the qtkeychain package
QTKEYCHAIN_VERSION=0.7.0

# The full version of the qtkeychain package
QTKEYCHAIN_FULL_VERSION="${QTKEYCHAIN_VERSION}-1.0ppa1~@DISTRIBUTION@1"

# The tag of the qtkeychain package
QTKEYCHAIN_TAG="v${QTKEYCHAIN_VERSION}"

# The version of the nextcloud-client package
NEXTCLOUD_CLIENT_VERSION=2.2.4

# The FULL version of the nextcloud-client package
NEXTCLOUD_CLIENT_FULL_VERSION="${NEXTCLOUD_CLIENT_VERSION}-1.2~@DISTRIBUTION@1"

# The tag of the nextcloud-client package
NEXTCLOUD_CLIENT_TAG="v${NEXTCLOUD_CLIENT_VERSION}"

# The number of CPUs that can be used for paralel builds
NUMCPUS=4
