#!/bin/bash

#
# picoSH microSD card image build script
#

PICOSH_SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source $PICOSH_SCRIPTS/include/environment.sh

IMAGE_NAME=${1:-picosh}
IMAGE_SIZE=2048

SRC=$PICOSH_STAGING/src-image-${IMAGE_NAME}
rm -rf $SRC
mkdir -p $SRC

pushd $SRC

# Initialize the image
echo "Initializing ${IMAGE_NAME}.img [$IMAGE_SIZE MiB]"
dd if=/dev/zero of=${IMAGE_NAME}.img bs=1M seek=$IMAGE_SIZE count=0 >/dev/null 2>&1

# Create a loop device for the image
DEVICE=$(sudo losetup --find --show ${IMAGE_NAME}.img)
DEVICE_P1=${DEVICE}p1
DEVICE_P2=${DEVICE}p2

# Partition the image (per https://linux-sunxi.org/Bootable_SD_card#Partitioning)
# Partition 1 (BOOT): starts at sector 2048 (1M), has a size of 16M, and ends at sector 34,815
# Partition 2 (PICOSH): starts at sector 34,816, has a size of IMAGE_SIZE, and consumes the remaining space
echo "Partitioning the image"
cat <<EOT | sudo sfdisk $DEVICE >>$PICOSH_BUILD_LOG 2>&1
1M,16M,c
,,L
EOT

# Re-read the new partition table
# Note: sfdisk cannot do this, and without running partprobe DEVICE_P1 and DEVICE_P2 would not exist
sudo partprobe $DEVICE

# Create filesystems
sudo mkfs.vfat -n boot ${DEVICE_P1} >>$PICOSH_BUILD_LOG 2>&1
sudo mkfs.ext4 -L picosh ${DEVICE_P2} >>$PICOSH_BUILD_LOG 2>&1

# Mount the image
mkdir -p boot
sudo mount -t vfat ${DEVICE_P1} boot
mkdir -p picosh
sudo mount -t ext4 ${DEVICE_P2} picosh

# Install the bootloader
echo "Installing the bootloader"
# Note: conv=notrunc is important, dd may truncate the image without it
dd if=$PICOSH_BUILD/u-boot-sunxi-with-spl.bin of=picosh.img bs=1024 seek=8 conv=notrunc >/dev/null 2>&1
sudo cp $PICOSH_BUILD/boot.scr boot/

# Install the kernel
echo "Installing the kernel"
sudo cp $PICOSH_BUILD/uImage boot/
sudo cp $PICOSH_BUILD/sun8i-r16-clockworkpi-cpi3-hdmi.dtb boot/
sudo cp $PICOSH_BUILD/sun8i-r16-clockworkpi-cpi3.dtb boot/

# Install the root fileystem
sudo tar -xzf $PICOSH_BUILD/rootfs.tar.gz -C picosh/

# Clean up
sudo umount boot
# sudo losetup -d $DEVICE_P1
sudo umount picosh
# sudo losetup -d $DEVICE_P2
sudo losetup -d $DEVICE

# Compress the image
echo "Compressing the image"
gzip ${IMAGE_NAME}.img

# Move build artifact(s)
mv ${IMAGE_NAME}.img.gz $PICOSH_BUILD/

popd
