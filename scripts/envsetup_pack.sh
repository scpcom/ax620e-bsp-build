#BOARD_DTS=m5stack-ax630c-module-llm
#BOARD_DTS=m5stack-ax630c-lite
BOARD_DTS=nanokvm_pro_arm64_k419

UBOOT_ARCH=arm
KERNEL_ARCH=arm64

TOOLCHAIN_ROOT=`pwd`/toolchain
PACK_OUTPUT_DIR=`pwd`/build/${BOARD_DTS}
PACK_INSTALL_DIR=`pwd`/install/${BOARD_DTS}

BOARD_BIN=`pwd`/axerabin/ax630c
BOARD_FW=`pwd`/axerabin/firmware
#GERNERAL_BIN=`pwd`/general_bin_ax630c
GERNERAL_BIN=`pwd`/axerabin/tools/bin

#CROSS_COMPILE=aarch64-linux-gnu-
#export PATH=$TOOLCHAIN_ROOT/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin:$PATH

CROSS_COMPILE=aarch64-none-linux-gnu-
export PATH=$TOOLCHAIN_ROOT/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin:$PATH
