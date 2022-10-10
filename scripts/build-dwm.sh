#!/bin/bash

set -e

#
# dwm build script
#

PICOSH_SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source $PICOSH_SCRIPTS/include/apply-patches.sh

pushd $SRC

# Apply patches
# echo "Applying patches"
apply-patches $PICOSH_PATCHES/dwm-${VERSION}

# Build dwm
echo "Building dwm"
export CROSS_COMPILE=arm-linux-gnueabihf-
make >>$PICOSH_BUILD_LOG 2>&1

# Copy build artifact(s)
sudo tar -cpzf $PICOSH_BUILD/dwm.tar.gz .

popd
