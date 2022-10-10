#!/bin/bash

# FIXME: Why does the picosh home directory get the wrong group?
chown -R picosh:picosh /home/picosh

# FIXME: Remove hack to have PIC0-8 read the correct configuration
ln -s /home/picosh/.lexaloffle /root/.lexaloffle

# Expand the root filesystem
/home/picosh/post-install/expand-rootfs.sh

# Finished post-install step; remove scripts to avoid running post-install again
sed -i '/post-install\/run/d' /home/picosh/.profile
rm -rf /home/picosh/post-install/
sleep 4
shutdown -r now