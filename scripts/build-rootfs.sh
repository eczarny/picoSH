#!/bin/bash

#
# picoSH root filesystem build script
#

PICOSH_SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source $PICOSH_SCRIPTS/include/environment.sh

ROOTFS="rootfs"

SRC=$PICOSH_STAGING/src-rootfs
sudo rm -rf $SRC
mkdir -p $SRC

pushd $SRC

# Create the root filesystem using multistrap (see multistrap.conf for installed packages)
echo "Creating the root filesystem"
sudo multistrap -a armhf -d $ROOTFS -f $PICOSH_HOME/configs/multistrap.conf >>$PICOSH_BUILD_LOG 2>&1

# Configuration needs to be done on the target hardware, use QEMU to emulate it
sudo cp /usr/bin/qemu-arm-static $ROOTFS/usr/bin

# Mount the host device tree to the root filesystem
sudo mount --bind /dev/ $ROOTFS/dev/

# Configure the root filesystem
echo "Configuring the root filesystem"
sudo cp $PICOSH_HOME/scripts/rootfs/config.sh $ROOTFS
sudo chroot $ROOTFS /bin/bash ./config.sh >>$PICOSH_BUILD_LOG 2>&1

# Add the picosh user and group
sudo chroot $ROOTFS adduser --disabled-password --gecos "" picosh >/dev/null 2>&1
sudo chroot $ROOTFS usermod --append --groups audio,video,input,render,sudo,tty picosh >/dev/null 2>&1

# Copy configuration files, scripts, and firmware
sudo rsync -iclrD $PICOSH_HOME/rootfs/* $ROOTFS/

# Set empty passwords for root and picosh users
sudo chroot $ROOTFS passwd -d root >/dev/null 2>&1
sudo chroot $ROOTFS passwd -d picosh >/dev/null 2>&1

# TODO: Determine if enabling systemd-networkd for DHCP is neecessary when using iwd
# sudo chroot $ROOTFS systemctl enable systemd-networkd >/dev/null 2>&1

# TODO: Enable connman-iwd service
# sudo chroot $ROOTFS systemctl enable connman-iwd >/dev/null 2>&1

# Install dwm
mkdir $ROOTFS/home/picosh/dwm
cp $PICOSH_BUILD/dwm.tar.gz $ROOTFS/home/picosh/dwm
sudo chroot $ROOTFS bash -x <<EOF
cd /home/picosh/dwm
tar -xzf dwm.tar.gz
make install >/dev/null 2>&1
EOF

# Install slstatus
mkdir $ROOTFS/home/picosh/slstatus
cp $PICOSH_BUILD/slstatus.tar.gz $ROOTFS/home/picosh/slstatus
sudo chroot $ROOTFS bash -x <<EOF
cd /home/picosh/slstatus
tar -xzf slstatus.tar.gz
make install >/dev/null 2>&1
EOF

# Kill processes running in root filesystem
sudo fuser -sk $ROOTFS

# Cleanup and unmount the device tree
sudo rm $ROOTFS/usr/bin/qemu-arm-static
sudo rm $ROOTFS/config.sh
sudo umount $ROOTFS/dev/

# Archive the root filesystem
echo "Archiving the root filesystem"
sudo tar -C $ROOTFS -cpzf $PICOSH_BUILD/rootfs.tar.gz .

popd
