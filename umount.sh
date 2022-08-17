umount /mnt
vgchange -an vg_livecd
qemu-nbd --disconnect /dev/nbd0
