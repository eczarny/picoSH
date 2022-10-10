#!/bin/bash

set -e

#
# Kernel build script
#

PICOSH_SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source $PICOSH_SCRIPTS/include/apply-patches.sh

pushd $SRC

# Apply patches
echo "Applying patches"
apply-patches $PICOSH_PATCHES/linux-${VERSION}

# Build Linux
echo "Building Linux"
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
make clockworkpi-cpi3_defconfig >>$PICOSH_BUILD_LOG 2>&1
make -j$(nproc) >>$PICOSH_BUILD_LOG 2>&1

# Make the Das U-Boot Linux kernel image
mkimage -A arm -O linux -T kernel -C none -a 0x40008000 -e 0x40008000 -n "Linux kernel" -d arch/arm/boot/zImage uImage >>$PICOSH_BUILD_LOG 2>&1
chmod +x uImage

# Install kernel modules
echo "Installing kernel modules"
sudo mkdir -p rootfs/
sudo tar -xzf $PICOSH_BUILD/rootfs.tar.gz -C rootfs/
sudo make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=rootfs/ modules_install >>$PICOSH_BUILD_LOG 2>&1
sudo tar -C rootfs -cpzf $PICOSH_BUILD/rootfs.tar.gz .

# Copy build artifact(s)
cp uImage $PICOSH_BUILD/
cp arch/arm/boot/dts/sun8i-r16-clockworkpi-cpi3-hdmi.dtb $PICOSH_BUILD/
cp arch/arm/boot/dts/sun8i-r16-clockworkpi-cpi3.dtb $PICOSH_BUILD/

popd
