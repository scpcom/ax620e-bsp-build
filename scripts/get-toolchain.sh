#!/bin/sh -e
. ./scripts/envsetup_pack.sh

DOWNLOAD_PATH=`pwd`/build/dl
[ "X${TOOLCHAIN_ROOT}" != "X" ] || TOOLCHAIN_ROOT=`pwd`/toolchain

[ "X${CROSS_COMPILE}" != "X" ] || CROSS_COMPILE=aarch64-none-linux-gnu-

if false ; then
CROSS_COMPILE=aarch64-linux-gnu-
export PATH=$TOOLCHAIN_ROOT/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin:$PATH

if [ ! -e $TOOLCHAIN_ROOT/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin ]; then
  mkdir -p $DOWNLOAD_PATH
  cd $DOWNLOAD_PATH
  wget -N http://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
  cd - > /dev/null

  mkdir -p $TOOLCHAIN_ROOT
  tar -xvf $DOWNLOAD_PATH/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz -C $TOOLCHAIN_ROOT/
fi
fi

if [ "X${CROSS_COMPILE}" = "Xarm-none-linux-gnueabihf-" ]; then
export PATH=$TOOLCHAIN_ROOT/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/bin:$PATH

if [ ! -e $TOOLCHAIN_ROOT/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/bin ]; then
  mkdir -p $DOWNLOAD_PATH
  cd $DOWNLOAD_PATH
  wget -N https://developer.arm.com/-/media/files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf.tar.xz
  cd - > /dev/null

  mkdir -p $TOOLCHAIN_ROOT
  tar -xvf $DOWNLOAD_PATH/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf.tar.xz  -C $TOOLCHAIN_ROOT/
fi

else
export PATH=$TOOLCHAIN_ROOT/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin:$PATH

if [ ! -e $TOOLCHAIN_ROOT/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin ]; then
  mkdir -p $DOWNLOAD_PATH
  cd $DOWNLOAD_PATH
  wget -N https://developer.arm.com/-/media/files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz
  cd - > /dev/null

  mkdir -p $TOOLCHAIN_ROOT
  tar -xvf $DOWNLOAD_PATH/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz  -C $TOOLCHAIN_ROOT/
fi
fi

echo OK
