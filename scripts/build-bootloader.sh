#!/bin/bash

set -e

#
# Bootloader build script
#

PICOSH_SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source $PICOSH_SCRIPTS/include/apply-patches.sh

pushd $SRC

# Apply patches
echo "Applying patches"
apply-patches $PICOSH_PATCHES/u-boot-${VERSION}

# Build Das U-Boot
echo "Building u-boot"
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
make clockworkpi-cpi3_defconfig >>$PICOSH_BUILD_LOG 2>&1
make -j$(nproc) >>$PICOSH_BUILD_LOG 2>&1

# Make the Das U-Boot boot script image
mkimage -C none -A arm -T script -d $PICOSH_CONFIGS/boot.cmd boot.scr >>$PICOSH_BUILD_LOG 2>&1

# Copy build artifact(s)
cp u-boot-sunxi-with-spl.bin $PICOSH_BUILD/
cp boot.scr $PICOSH_BUILD/

popd
