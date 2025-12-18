#!/bin/sh -e
#BOARD_DTS=m5stack-ax630c-module-llm
#BOARD_DTS=m5stack-ax630c-lite
BOARD_DTS=nanokvm_pro_arm64_k419

TOOLCHAIN_ROOT=`pwd`/toolchain
UBOOT_OUTPUT_DIR=`pwd`/build/${BOARD_DTS}/u-boot

BOARD_CFG=AX630C_m5stack_LLM_module_defconfig
[ "${BOARD_DTS}" != "m5stack-ax630c-lite" ] || BOARD_CFG=AX630C_m5stack_LITE_defconfig
[ "${BOARD_DTS}" != "nanokvm_pro_arm64_k419" ] || BOARD_CFG=nanokvm_pro_defconfig

#CROSS_COMPILE=aarch64-linux-gnu-
#export PATH=$TOOLCHAIN_ROOT/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin:$PATH

CROSS_COMPILE=aarch64-none-linux-gnu-
export PATH=$TOOLCHAIN_ROOT/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin:$PATH

make -C u-boot ARCH=arm CROSS_COMPILE=$CROSS_COMPILE O=$UBOOT_OUTPUT_DIR dtb-y=${BOARD_DTS}.dtb EXTRA_CFLAGS=-DUBOOT_IMG_HEADER_BASE=0x5C000000 DEVICE_TREE=${BOARD_DTS} ${BOARD_CFG}
make -C u-boot ARCH=arm CROSS_COMPILE=$CROSS_COMPILE O=$UBOOT_OUTPUT_DIR dtb-y=${BOARD_DTS}.dtb EXTRA_CFLAGS=-DUBOOT_IMG_HEADER_BASE=0x5C000000 DEVICE_TREE=${BOARD_DTS} -j `nproc`

echo OK
