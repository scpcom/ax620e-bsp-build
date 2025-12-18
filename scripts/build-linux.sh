#!/bin/sh -e
#BOARD_DTS=m5stack-ax630c-module-llm
#BOARD_DTS=m5stack-ax630c-lite
BOARD_DTS=nanokvm_pro_arm64_k419

ARCH=arm64

TOOLCHAIN_ROOT=`pwd`/toolchain
KERNEL_OUTPUT_DIR=`pwd`/build/${BOARD_DTS}/linux
PACK_INSTALL_DIR=`pwd`/install/${BOARD_DTS}

KERNEL_CFG=m5stack_AX630C_emmc_arm64_k419_defconfig
[ "${BOARD_DTS}" != "nanokvm_pro_arm64_k419" ] || KERNEL_CFG=nanokvm_pro_emmc_arm64_k419_defconfig

#CROSS_COMPILE=aarch64-linux-gnu-
#export PATH=$TOOLCHAIN_ROOT/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin:$PATH

CROSS_COMPILE=aarch64-none-linux-gnu-
export PATH=$TOOLCHAIN_ROOT/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin:$PATH

# Remove + from kernel version
cd linux
sed -i s/'echo "+"'/'echo ""'/g scripts/setlocalversion
cd - > /dev/null

#make -C linux distclean
make -C linux ARCH=${ARCH} CROSS_COMPILE=$CROSS_COMPILE O=$KERNEL_OUTPUT_DIR ${KERNEL_CFG}

make -C linux ARCH=${ARCH} CROSS_COMPILE=$CROSS_COMPILE O=$KERNEL_OUTPUT_DIR -j `nproc`
make -C linux ARCH=${ARCH} CROSS_COMPILE=$CROSS_COMPILE O=$KERNEL_OUTPUT_DIR modules_install INSTALL_MOD_PATH=${KERNEL_OUTPUT_DIR}/ko headers_install INSTALL_HDR_PATH=${KERNEL_OUTPUT_DIR}/${ARCH}/usr
#make -C linux ARCH=${ARCH} CROSS_COMPILE=$CROSS_COMPILE O=$KERNEL_OUTPUT_DIR -j `nproc` bindeb-pkg

cd linux
git restore scripts/setlocalversion
cd - > /dev/null

mkdir -p ${PACK_INSTALL_DIR}/ko
find ${KERNEL_OUTPUT_DIR}/ko -name '*.ko' -exec cp -f -p {} ${PACK_INSTALL_DIR}/ko/ \;

echo OK
