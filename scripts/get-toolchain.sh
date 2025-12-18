#!/bin/sh -e
DOWNLOAD_PATH=`pwd`/build/dl
TOOLCHAIN_ROOT=`pwd`/toolchain

if false ; then
CROSS_COMPILE=aarch64-linux-gnu-
export PATH=$TOOLCHAIN_ROOT/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin:$PATH

if [ ! -e $TOOLCHAIN_ROOT/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin ]; then
  mkdir -p $DOWNLOAD_PATH
  cd $DOWNLOAD_PATH
  wget -N http://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
  cd - > /dev/null

  mkdir -p $TOOLCHAIN_ROOT
  sudo tar -xvf gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz -C $TOOLCHAIN_ROOT/
fi
fi

CROSS_COMPILE=aarch64-none-linux-gnu-
export PATH=$TOOLCHAIN_ROOT/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin:$PATH

if [ ! -e $TOOLCHAIN_ROOT/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin ]; then
  mkdir -p $DOWNLOAD_PATH
  cd $DOWNLOAD_PATH
  wget -N https://developer.arm.com/-/media/files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz
  cd - > /dev/null

  mkdir -p $TOOLCHAIN_ROOT
  sudo tar -xvf $DOWNLOAD_PATH/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz  -C $TOOLCHAIN_ROOT/
fi

echo OK
