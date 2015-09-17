
#!/bin/sh
# Pogoplug Series 4 U-Boot Installer - r1
# Maintainer: Kevin Mihelich <kevin@archlinuxarm.org>

echo "######################################"
echo "##"
echo "## Pogoplug Series 4 U-Boot Installer"
echo "##"
echo "######################################"
echo ""

cd /tmp

echo "# Checking board revision..."

BOARDVER=`/usr/local/cloudengines/bin/blparam | grep -e '^ceboardver=' | sed 's/^ceboardver=//'`
if [ "$BOARDVER" != "PPV4A3" -a "$BOARDVER" != "PPV4A1" ]
then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "ABORTING!!! UNSUPPORTED MODEL"
    echo "==================================="
    echo "This installer is ONLY for Series 4"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit
fi

#######
## GET files
#######
echo "#############################"
echo "## RETRIEVING FILES"
echo "# Downloading U-Boot files.."
wget http://archlinuxarm.org/os/ppv4/uboot.bin.gz

echo "# Verifying MD5"
/usr/bin/md5sum /tmp/uboot.bin.gz > rfs.md5
GOODMD5="0c1c0cea79b5481afed7c3521c79d722"
RFSMD5=`grep $GOODMD5 rfs.md5 | cut -d' ' -f1`
if [ "$GOODMD5" != "$RFSMD5" ]; then
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "MD5 verification Failure."
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	rm -f uboot.* rfs.md5
	exit
fi

echo "# Decompressing"
gunzip uboot.bin.gz

echo ""
echo "#############################"
echo "## FLASHING NAND.."
echo "# Erasing mtd0 @ 0x100000 for 4 erase blocks (new U-Boot location)"
/usr/sbin/flash_erase /dev/mtd0 0x100000 4

echo "# Flashing U-Boot.."
/usr/sbin/nandwrite -p -s 0x100000 /dev/mtd0 /tmp/uboot.bin

echo "# Done"
echo ""

echo "#############################"
echo "## UPDATING ENVIRONMENT For Archlinux"
/usr/local/cloudengines/bin/blparam arcNumber=3960 > /dev/null
/usr/local/cloudengines/bin/blparam mainlineLinux=yes > /dev/null
/usr/local/cloudengines/bin/blparam bootcmd='if usb start; then run alarm_boot; else nand read 0x800000 0x100000 0x73d0c; go 0x800000; fi' > /dev/null
/usr/local/cloudengines/bin/blparam alarm_boot='ide reset; run alarm_revert; if ide part 0; then run alarm_ide; else setenv isDisk no; fi; run alarm_usb' > /dev/null
/usr/local/cloudengines/bin/blparam alarm_revert='if fatls usb 0:1 /revert; then setenv mainlineLinux no; setenv arcNumber; setenv bootcmd run boot_nand; saveenv; reset; fi' > /dev/null
/usr/local/cloudengines/bin/blparam alarm_args='setenv bootargs console=ttyS0,115200 root=$device rootwait rootfstype=ext3' > /dev/null
/usr/local/cloudengines/bin/blparam alarm_which='if test $isDisk = yes; then setenv device /dev/sdb1; else setenv device /dev/sda1; fi' > /dev/null
/usr/local/cloudengines/bin/blparam alarm_ide='if ext2load ide 0:1 0x800000 /boot/uImage; then setenv device /dev/sda1; run alarm_args; bootm 0x800000; else setenv isDisk yes; fi' > /dev/null
/usr/local/cloudengines/bin/blparam alarm_usb='if ext2load usb 0:1 0x800000 /boot/uImage; then run alarm_which; run alarm_args; bootm 0x800000; fi' > /dev/null

echo "## UPDATING ENVIRONMENT For Debian"

/usr/local/cloudengines/bin/blparam debian_usb='if ext2load usb 0:1 0x800000 /boot/uImage; then run alarm_which; run alarm_args; fi; if ext2load usb 0:1 0x1100000 /boot/uInitrd; then bootm 0x800000 0x1100000; else bootm 0x800000; fi'
/usr/local/cloudengines/bin/blparam isDisk='no'
/usr/local/cloudengines/bin/blparam debian_ide='if ext2load ide 0:1 0x800000 /boot/uImage; then setenv device /dev/sda1; run alarm_args; if ext2load ide 0:1 0x1100000 /boot/uInitrd; then bootm 0x800000 0x1100000; else bootm 0x800000; fi; else setenv isDisk yes; fi'
/usr/local/cloudengines/bin/blparam debian_boot='ide reset; run alarm_revert; if ide part 0; then run debian_ide; else setenv isDisk no; fi; run debian_usb'
/usr/local/cloudengines/bin/blparam bootcmd='if usb start; then run debian_boot; else nand read 0x800000 0x100000 0x73d0c; go 0x800000; fi'

echo ""
echo "#############################"	
echo "## U-Boot install complete!"
