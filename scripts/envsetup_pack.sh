BOARD_CHIP=ax630c
BOARD_FAMILY=ax620e_emmc

#BOARD_DTS=m5stack-ax630c-module-llm
#BOARD_DTS=m5stack-ax630c-lite
#BOARD_DTS=maixcam2_arm64_k419
BOARD_DTS=nanokvm_pro_arm64_k419

UBOOT_ARCH=arm
KERNEL_ARCH=arm64

TOOLCHAIN_ROOT=`pwd`/toolchain
PACK_OUTPUT_DIR=`pwd`/build/${BOARD_DTS}
PACK_INSTALL_DIR=`pwd`/install/${BOARD_DTS}

BOARD_BIN=`pwd`/axerabin/${BOARD_CHIP}
BOARD_FW=`pwd`/axerabin/firmware
#GERNERAL_BIN=`pwd`/general_bin_ax630c
GERNERAL_BIN=`pwd`/axerabin/tools/bin

#CROSS_COMPILE_PATH=$TOOLCHAIN_ROOT/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu
#CROSS_COMPILE=aarch64-linux-gnu-

CROSS_COMPILE_PATH=$TOOLCHAIN_ROOT/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu
CROSS_COMPILE=aarch64-none-linux-gnu-

export PATH=$CROSS_COMPILE_PATH/bin:$PATH

ax620e_emmc_blkdevparts="
768K(spl)
512K(ddrinit)
256K(atf)
256K(atf_b)
1536K(uboot)
1536K(uboot_b)
1M(env)
6M(logo)
6M(logo_b)
1M(optee)
1M(optee_b)
1M(dtb)
1M(dtb_b)
64M(kernel)
64M(kernel_b)
128M(boot)"

ax620e_Qnand_blkdevparts="
1M(spl)
512K(ddrinit)
1M(uboot)
512K(env)
4M(param)
512K(dtb)
6M(kernel)"

blkdevparts=$ax620e_emmc_blkdevparts
[ "${BOARD_FAMILY}" != "ax620e_Qnand" ] || blkdevparts=$ax620e_Qnand_blkdevparts
