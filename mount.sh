qemu-nbd --connect=/dev/nbd0 makeos-CentOS-20150504.qcow2
sleep 1
mount /dev/vg_livecd/lv_root /mnt
