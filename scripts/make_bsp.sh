#!/bin/sh -e
green="\e[0;32m"
red="\e[0;31m"
blue="\e[0;34m"
end_color="\e[0m"

[ "X$GIT_REF" = "X" ] && GIT_REF="main"

BUILDDIR="/ax_bsp_sdk"

if [ "X$BOARD_DTS" = "X" ]; then
echo "${red}BOARD_DTS is not set${end_color}"
exit 1
fi


SDK_BOARD_LINK=${BOARD_DTS}

echo "${blue}Board: ${BOARD_DTS}${end_color}"

bs=${BUILDDIR}/sdk-prepare-checkout-stamp
if [ ! -e $bs ]; then
  echo "\n${green}Checking out SDK for ${BOARD_DTS}${end_color}\n"
  git clone -b main https://github.com/scpcom/ax620e-bsp-build ${BUILDDIR}
  cd ${BUILDDIR} && git checkout ${GIT_REF}
  cd ${BUILDDIR} && git submodule update --init --recursive --depth=1
  touch $bs
fi

bs=${BUILDDIR}/sdk-prepare-patch-stamp
if [ ! -e $bs ]; then
  echo "\n${green}Patching SDK for ${BOARD_DTS}${end_color}\n"
  cd ${BUILDDIR} && ./scripts/prepare-host.sh
  touch $bs
fi

bs=${BUILDDIR}/sdk-compile-stamp
if [ ! -e $bs ]; then
  echo "\n${green}Building SDK for ${BOARD_DTS}${end_color}\n"
  cd ${BUILDDIR} && ./build.sh --board=${SDK_BOARD_LINK}
  touch $bs
fi

bs=${BUILDDIR}/sdk-output-stamp
if [ ! -e $bs ]; then
  echo "\n${green}Packing Image for ${BOARD_DTS}${end_color}\n"
  cp -p ${BUILDDIR}/install/${BOARD_DTS}/*.bin* ${BUILDDIR}/install/${BOARD_DTS}/*.img* /output/
  echo "\n${green}Image for ${BOARD_DTS} is ${BOARD_DTS}.img.xz${end_color}\n"
  touch $bs
fi
