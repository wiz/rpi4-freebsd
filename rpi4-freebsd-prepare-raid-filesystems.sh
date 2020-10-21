cd /root
wget https://github.com/pftf/RPi4/releases/download/v1.17/RPi4_UEFI_Firmware_v1.17.zip

dmesg
ls -la /dev/da1*
ls -la /dev/da2*
# gpart destroy -F ${disk}

# mount freebsd 13 img
mdconfig -t vnode ~wiz/FreeBSD-13.0-CURRENT-arm64-aarch64-RPI3-20200702-r362853.img
mount /dev/md0s2a /loop
cd /loop

# for each SSD
for disk in da1 da2
do

# create partition table
gpart create -s mbr /dev/${disk}
gpart add -s 50M -t fat32lba ${disk}
gpart add -t freebsd ${disk}
gpart create -s bsd ${disk}s2
gpart add -s 300M -t freebsd-ufs ${disk}s2
gpart add -t freebsd-zfs ${disk}s2
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ${disk}s2

# create msdos boot partition
newfs_msdos -L fat32lba /dev/${disk}s1
mount_msdosfs /dev/${disk}s1 /mnt
cd /mnt
tar zvxf ~wiz/rpi4-freebsd-boot.tgz
unzip -f /root/RPi4_UEFI_Firmware_v1.17.zip
cp bcm2711-rpi-4-b.dtb dtb/broadcom/bcm2711-rpi-4-b.dtb
cd /root
umount /mnt

# create freebsd boot partition
newfs /dev/${disk}s2a
cd /loop
rsync -av boot /mnt
cd /mnt
echo 'zfs_load="YES"' >> boot/loader.conf
echo 'opensolaris_load="YES"' >> boot/loader.conf
#echo 'vfs.root.mountfrom="zfs:rpiraid"' >> boot/loader.conf
echo 'vfs.root.mountfrom="ufs:/dev/da0s2a"' >> boot/loader.conf
cd /root
umount /mnt

# done
done

# create freebsd OS partition raid zpool
zpool create rpiraid da1s2b da2s2b
tar cf - .|(cd /rpiraid && tar xvf -)
cd /rpiraid
rm -rf boot
echo 'zfs_enable="YES"' > etc/rc.conf
cd /root
zpool export rpiraid
