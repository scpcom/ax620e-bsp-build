#!/bin/sh -e
. ./scripts/envsetup_pack.sh

UBOOT_OUTPUT_DIR=$PACK_OUTPUT_DIR/u-boot

BOARD_CFG=AX630C_m5stack_LLM_module_defconfig
[ "${BOARD_DTS}" != "m5stack-ax630c-lite" ] || BOARD_CFG=AX630C_m5stack_LITE_defconfig
[ "${BOARD_DTS}" != "nanokvm_pro_arm64_k419" ] || BOARD_CFG=nanokvm_pro_defconfig

make -C u-boot ARCH=${UBOOT_ARCH} CROSS_COMPILE=$CROSS_COMPILE O=$UBOOT_OUTPUT_DIR dtb-y=${BOARD_DTS}.dtb EXTRA_CFLAGS=-DUBOOT_IMG_HEADER_BASE=0x5C000000 DEVICE_TREE=${BOARD_DTS} ${BOARD_CFG}
make -C u-boot ARCH=${UBOOT_ARCH} CROSS_COMPILE=$CROSS_COMPILE O=$UBOOT_OUTPUT_DIR dtb-y=${BOARD_DTS}.dtb EXTRA_CFLAGS=-DUBOOT_IMG_HEADER_BASE=0x5C000000 DEVICE_TREE=${BOARD_DTS} -j `nproc`

echo OK
