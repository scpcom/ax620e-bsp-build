#!/bin/sh -e
#GERNERAL_BIN=`pwd`/general_bin_ax630c
GERNERAL_BIN=`pwd`/axerabin/tools/bin
PACKED_BIN=$1

[ "X$PACKED_BIN" != "X" ] || exit 1

./scripts/ax_unpack_bin.sh $PACKED_BIN
./scripts/repack-zImage.sh -u ${PACKED_BIN}.unpacked

cp -p ${PACKED_BIN}.unpacked_unpacked/initramfs.cpio ${PACKED_BIN}.initramfs_rootfs.cpio  
rm -rf ${PACKED_BIN}.unpacked_unpacked/

echo OK
