#!/bin/sh -e
. ./scripts/envsetup_pack.sh

KERNEL_OUTPUT_DIR=$PACK_OUTPUT_DIR/linux
KERNEL_CFG=m5stack_AX630C_emmc_arm64_k419_defconfig
[ "${BOARD_DTS}" != "maixcam2_arm64_k419" ] || KERNEL_CFG=maixcam2_emmc_arm64_k419_defconfig
[ "${BOARD_DTS}" != "nanokvm_pro_arm64_k419" ] || KERNEL_CFG=nanokvm_pro_emmc_arm64_k419_defconfig

if [ "X$1" = "Xclean" ]; then
  make -C linux ARCH=${KERNEL_ARCH} CROSS_COMPILE=$CROSS_COMPILE O=$KERNEL_OUTPUT_DIR clean
  exit 0
fi

cd linux
if [ -e $PACK_INSTALL_DIR/initramfs_rootfs.cpio ]; then
  sed -i 's|^CONFIG_INITRAMFS_SOURCE=.*|CONFIG_INITRAMFS_SOURCE="../../../install/'${BOARD_DTS}'/initramfs_rootfs.cpio"|g' arch/${KERNEL_ARCH}/configs/${KERNEL_CFG}
else
  sed -i 's|^CONFIG_INITRAMFS_SOURCE=.*|CONFIG_INITRAMFS_SOURCE=""|g' arch/${KERNEL_ARCH}/configs/${KERNEL_CFG}
fi
# Remove + from kernel version
sed -i s/'echo "+"'/'echo ""'/g scripts/setlocalversion
# Keep sublevel at 125
sed -i s/'^SUBLEVEL = .*'/'SUBLEVEL = 125'/g Makefile
cd - > /dev/null

#make -C linux distclean
make -C linux ARCH=${KERNEL_ARCH} CROSS_COMPILE=$CROSS_COMPILE O=$KERNEL_OUTPUT_DIR ${KERNEL_CFG}

make -C linux ARCH=${KERNEL_ARCH} CROSS_COMPILE=$CROSS_COMPILE O=$KERNEL_OUTPUT_DIR -j `nproc`
make -C linux ARCH=${KERNEL_ARCH} CROSS_COMPILE=$CROSS_COMPILE O=$KERNEL_OUTPUT_DIR modules_install INSTALL_MOD_PATH=${KERNEL_OUTPUT_DIR}/ko headers_install INSTALL_HDR_PATH=${KERNEL_OUTPUT_DIR}/${ARCH}/usr
[ "X$1" != "Xbindeb-pkg" ] || make -C linux ARCH=${KERNEL_ARCH} CROSS_COMPILE=$CROSS_COMPILE O=$KERNEL_OUTPUT_DIR -j `nproc` bindeb-pkg

cd linux
git restore arch/${KERNEL_ARCH}/configs/${KERNEL_CFG}
git restore scripts/setlocalversion
git restore Makefile
cd - > /dev/null

mkdir -p ${PACK_INSTALL_DIR}/ko
find ${KERNEL_OUTPUT_DIR}/ko -name '*.ko' -exec cp -f -p {} ${PACK_INSTALL_DIR}/ko/ \;

fakeroot tar -C ${PACK_INSTALL_DIR} -czvf ${PACK_INSTALL_DIR}/${BOARD_DTS}-ko.tar.gz ko

echo OK
