dmesg
ls -la /dev/da1*
gpart create -s mbr /dev/da1
gpart add -s 50M -t fat32lba da1
gpart add -t freebsd da1
gpart create -s bsd da1s2
gpart add -t freebsd-zfs da1s2
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 da1s2

newfs_msdos -L fat32lba /dev/da1s1
mount_msdosfs /dev/da1s1 /mnt
cd /mnt
tar zvxf ~wiz/rpi4-freebsd-boot.tgz
cd /
umount /mnt

zpool create rpiroot /dev/da1s2a
zpool set bootfs=rpiroot rpiroot
mdconfig -t vnode ~wiz/FreeBSD-13.0-CURRENT-arm64-aarch64-RPI3-20200702-r362853.img
mount /dev/md0s2a /mnt
cd /mnt
tar cf - .|(cd /rpiroot && tar xvf -)
cd /rpiroot
echo 'zfs_load="YES"' >> boot/loader.conf
echo 'opensolaris_load="YES"' >> boot/loader.conf
echo 'vfs.root.mountfrom="zfs:rpiroot"' >> boot/loader.conf
echo 'zfs_enable="YES"' > etc/rc.conf
cd
zpool export rpiroot
