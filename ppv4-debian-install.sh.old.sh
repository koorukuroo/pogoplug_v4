echo "######################################"
echo "##"
echo "## Pogoplug Series 4 All-In-One Installer"
echo "## Script=Siraki@2014.03.02"
echo "##"
echo "######################################"
echo ""

echo "# Stopping Pogoplug service..."
killall hbwd

echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "## Format USB"
echo "#Input 'o'. It will erase all partitions in drive.#"
echo "#Input 'p' to display partition list.#"
echo "#Then Press 'n' and 'p'. (p means 'PRIMARY')#"
echo "#Press 1. Then press Enter 'twice'. Press 'w' to exit.#"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

/sbin/fdisk /dev/sda

echo ""
echo "# Formatting USB to EXT3"
cd /tmp
wget http://archlinuxarm.org/os/pogoplug/mke2fs
chmod +x mke2fs
./mke2fs -j -L /rootfs /dev/sda1
rm mke2fs
mkdir rootfs
mount /dev/sda1 rootfs
cd /tmp/rootfs

echo ""
echo "# Download 'DEBIAN'"
echo "Notice : It will be downloaded from POGOLINUX MIRROR"
# wget http://pogo.laikin.tk/Debian-3.14.0-kirkwood-tld-1-rootfs-bodhi.tar.bz2

echo ""
echo "# Debian-3.14.0 Download complete."
echo ""
echo " Decompress 'Debian-3.14.0'"

tar -xjf /tmp/rootfs/Debian-3.14.0-kirkwood-tld-1-rootfs-bodhi.tar.bz2
rm /tmp/rootfs/Debian-3.14.0-kirkwood-tld-1-rootfs-bodhi.tar.bz2
sync

echo ""
echo " unmounting rootfs"
cd ..
umount rootfs

echo ""
echo "## 'Debian install complete."
echo ""
echo "## Entering 'Part.2'"

# wget http://pogo.laikin.tk/ppv4-debian-install2.sh
chmod +x ppv4-debian-install2.sh
./ppv4-debian-install2.sh