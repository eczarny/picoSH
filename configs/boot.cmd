setenv bootargs console=ttyS0,115200n8 vt.global_cursor_default=0 fsck.repair=yes root=/dev/mmcblk0p2 rootfstype=ext4 rootwait rw init=/sbin/init noinitrd panic=10 ${extra}
load mmc 0 0x48000000 uImage
if gpio input pl11;
then
	load mmc 0 0x49000000 sun8i-r16-clockworkpi-cpi3.dtb;
else
	load mmc 0 0x49000000 sun8i-r16-clockworkpi-cpi3-hdmi.dtb;
fi;
bootm 0x48000000 - 0x49000000
