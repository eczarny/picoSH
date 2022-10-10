#!/bin/bash

#
# picoSH root filesystem configuration script
#

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
export LC_ALL=C LANGUAGE=C LANG=C
export RUNLEVEL=1

# Set selections for package configuration, see the debconfsee.txt file
if [ -d /tmp/preseeds/ ]; then
    for file in `ls -1 /tmp/preseeds/*`; do
        debconf-set-selections $file
    done
fi

mount proc -t proc /proc
# Configure installed packages
dpkg --configure -a
# These packages have a tendency to fail during configuration, so try again
dpkg --configure base-files
dpkg --configure bash
umount proc
# Configure locale (see https://wiki.debian.org/Locale)
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen; LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LANG=en_US.UTF-8 locale-gen
