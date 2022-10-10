#!/bin/bash

parted -s -a optimal -m /dev/mmcblk0 resizepart 2 100%
resize2fs -f /dev/mmcblk0p2
