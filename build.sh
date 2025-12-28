#!/bin/sh -e
. ./scripts/envsetup_pack.sh

AX_BOARD_LINK=$BOARD_DTS

while [ "$#" -gt 0 ]; do
	case "$1" in
	--board=*|--board-link=*)
		export AX_BOARD_LINK=`echo $1 | cut -d '=' -f 2-`
		shift
		;;
	*)
		break
		;;
	esac
done

if [ "$AX_BOARD_LINK" != "$BOARD_DTS" ]; then
  sed -i s/'^BOARD_DTS=.*'/'BOARD_DTS='$AX_BOARD_LINK/g  ./scripts/envsetup_pack.sh
  . ./scripts/envsetup_pack.sh
fi

./scripts/get-toolchain.sh

./scripts/build-u-boot.sh
./scripts/build-linux.sh

[ ! -e ${PACK_OUTPUT_DIR}/atf.bin     ] || ./scripts/ax_pack_bin.sh atf.bin atf.img 262144
[ ! -e ${PACK_OUTPUT_DIR}/optee.bin   ] || ./scripts/ax_pack_bin.sh optee.bin optee.img 1048576

[ ! -e ${PACK_OUTPUT_DIR}/ddrinit.bin ] || ./scripts/ax_sign_bin.sh ddrinit.bin ddrinit.img 524288
[ ! -e ${PACK_OUTPUT_DIR}/spl.bin     ] || ./scripts/ax_sign_bin.sh spl.bin spl.img 786432

[ ! -e ${PACK_OUTPUT_DIR}/logo.bmp    ] || ./scripts/ax_copy_bin.sh logo.bmp logo.img 6291456

./scripts/ax_pack_uboot.sh
./scripts/ax_pack_linux.sh
./scripts/ax_pack_dtb.sh

blkimgs="spl.img
ddrinit.img
atf.img
atf.img
uboot.bin
uboot.bin
env.bin
logo.img
logo.img
optee.img
optee.img
dtb.img
dtb.img
kernel.img
kernel.img"

LIP_IMAGE_FILE=${PACK_INSTALL_DIR}/emmc.img
rm -f ${LIP_IMAGE_FILE}
touch ${LIP_IMAGE_FILE}
p=-
for blkimg in $blkimgs ; do
  f=${PACK_INSTALL_DIR}/${blkimg}.tmp
  if [ ! -e $f ]; then
    rm -f ${LIP_IMAGE_FILE}
    break
  fi
  b=`stat -c %s $f`
  k=$(($b / 1024))
  m=$(($k / 1024))
  s=$(($m * 1024))
  n=$(basename $f | cut -d '.' -f 1)
  o=${m}M
  [ $n != $p ] || n=${n}_b
  [ $k = $s ] || o=${k}K
  [ "-" != $p ] || echo "blkdevparts=mmcblk0:"
  echo "${o}(${n})"
  cat $f >> ${LIP_IMAGE_FILE}
  p=$n
done

echo "All done."
echo
echo "Result can be found in:"
echo $PACK_INSTALL_DIR/
echo
