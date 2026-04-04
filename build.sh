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
  if  echo $AX_BOARD_LINK | grep -q -i ax620q_ ; then
    sed -i s/'^BOARD_CHIP=.*'/'BOARD_CHIP='ax620q/g  ./scripts/envsetup_pack.sh
  fi
  if  echo $AX_BOARD_LINK | grep -q _arm32_ ; then
    sed -i s/'^KERNEL_ARCH=.*'/'KERNEL_ARCH='arm/g  ./scripts/envsetup_pack.sh
    sed -i 's|^CROSS_COMPILE_PATH=.*|CROSS_COMPILE_PATH=''$TOOLCHAIN_ROOT/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf|g'  ./scripts/envsetup_pack.sh
    sed -i s/'^CROSS_COMPILE=.*'/'CROSS_COMPILE=''arm-none-linux-gnueabihf-'/g  ./scripts/envsetup_pack.sh
  fi
  if  echo $AX_BOARD_LINK | grep -q -i nand_ ; then
    sed -i s/'^BOARD_FAMILY=.*'/'BOARD_FAMILY='ax620e_Qnand/g  ./scripts/envsetup_pack.sh
  fi
  . ./scripts/envsetup_pack.sh
fi

mkdir -p ${PACK_OUTPUT_DIR}
for f in ${BOARD_BIN}/*.bin ${BOARD_BIN}/*.bmp ${BOARD_BIN}/*.ubi ; do
  [ -e $f ] || continue
  cp -p $f ${PACK_OUTPUT_DIR}/
done

mkdir -p ${PACK_INSTALL_DIR}
[ ! -e ${BOARD_FW}/${BOARD_CHIP}_initramfs_rootfs.cpio ] ||  cp -p ${BOARD_FW}/${BOARD_CHIP}_initramfs_rootfs.cpio ${PACK_INSTALL_DIR}/initramfs_rootfs.cpio

./scripts/get-toolchain.sh

./scripts/build-u-boot.sh
#./scripts/build-ramfs.sh
./scripts/build-linux.sh

splsize=786432
ddrsize=524288
atfsize=262144
ubosize=1572864
envsize=1048576
lgosize=6291456
optsize=1048576
parsize=4194304
dtbsize=1048576
krnsize=67108864
for part in $blkdevparts ; do
  s=$(echo $part | cut -d '(' -f 1)
  n=$(echo $part | cut -d '(' -f 2 | cut -d ')' -f 1)
  if echo $s | grep -q M ; then
    k=$(echo $s | sed s/'M$'/''/g)
    k=$(($k * 1024))
  else
    k=$(echo $s | sed s/'K$'/''/g)
  fi
  b=$(($k * 1024))
  [ "$n" != "boot" ] || n=bootfs
  [ "$n" != "spl"     ] || splsize=$b
  [ "$n" != "ddrinit" ] || ddrsize=$b
  [ "$n" != "atf"     ] || atfsize=$b
  [ "$n" != "uboot"   ] || ubosize=$b
  [ "$n" != "env"     ] || envsize=$b
  [ "$n" != "logo"    ] || lgosize=$b
  [ "$n" != "optee"   ] || optsize=$b
  [ "$n" != "param"   ] || parsize=$b
  [ "$n" != "dtb"     ] || dtbsize=$b
  [ "$n" != "kernel"  ] || krnsize=$b
done

[ ! -e ${PACK_OUTPUT_DIR}/atf.bin     ] || ./scripts/ax_pack_bin.sh atf.bin atf.img $atfsize
[ ! -e ${PACK_OUTPUT_DIR}/optee.bin   ] || ./scripts/ax_pack_bin.sh optee.bin optee.img $optsize

[ ! -e ${PACK_OUTPUT_DIR}/fdl-sd.bin  ] || ./scripts/ax_sign_spl.sh fdl-sd.bin fw.bin boot.bin 262144 -sd_fat
[ ! -e ${PACK_OUTPUT_DIR}/fdl.bin     ] || ./scripts/ax_sign_fdl.sh fdl.bin fw.bin fdl.bin 92160
[ ! -e ${PACK_OUTPUT_DIR}/fdl2.bin    ] || ./scripts/ax_sign_bin.sh fdl2.bin fdl2.bin -
[ ! -e ${PACK_OUTPUT_DIR}/ddrinit.bin ] || ./scripts/ax_sign_bin.sh ddrinit.bin ddrinit.img $ddrsize
[ ! -e ${PACK_OUTPUT_DIR}/spl.bin     ] || ./scripts/ax_sign_spl.sh spl.bin fw.bin spl.img $splsize

[ ! -e ${PACK_OUTPUT_DIR}/eip_ax620e.bin ] || ./scripts/ax_copy_bin.sh eip_ax620e.bin eip.bin -
[ ! -e ${PACK_OUTPUT_DIR}/logo.bmp    ] || ./scripts/ax_copy_bin.sh logo.bmp logo.img $lgosize
[ ! -e ${PACK_OUTPUT_DIR}/param.ubi   ] || ./scripts/ax_copy_bin.sh param.ubi param.img $parsize

./scripts/ax_pack_uboot.sh u-boot.bin $ubosize u-boot-initial-env $envsize
./scripts/ax_pack_linux.sh Image $krnsize
./scripts/ax_pack_dtb.sh ${BOARD_DTS}.dtb $dtbsize


ax630c_emmc_blkdev="blkdevparts=mmcblk0"
ax630c_emmc_blkimgs="spl.img
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

ax620q_emmc_blkimgs="spl.img
ddrinit.img
uboot.bin
uboot.bin
env.bin
logo.img
dtb.img
kernel.img"

ax620q_Qnand_blkdev="mtdparts=spi4.0"
ax620q_Qnand_blkimgs="spl.img
ddrinit.img
uboot.bin
env.bin
param.img
dtb.img
kernel.img"

blkdev=$ax630c_emmc_blkdev
blkimgs=$ax630c_emmc_blkimgs
LIP_IMAGE_FILE=${PACK_INSTALL_DIR}/emmc.img
[ "${BOARD_CHIP}-${BOARD_FAMILY}" != "ax620q-ax620e_emmc"  ] || blkimgs=$ax620q_emmc_blkimgs
[ "${BOARD_CHIP}-${BOARD_FAMILY}" != "ax620q-ax620e_Qnand" ] || blkdev=$ax620q_Qnand_blkdev
[ "${BOARD_CHIP}-${BOARD_FAMILY}" != "ax620q-ax620e_Qnand" ] || blkimgs=$ax620q_Qnand_blkimgs
[ "${BOARD_CHIP}-${BOARD_FAMILY}" != "ax620q-ax620e_Qnand" ] || LIP_IMAGE_FILE=${PACK_INSTALL_DIR}/nand.img

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
  [ "-" != $p ] || echo "${blkdev}:"
  echo "${o}(${n})"
  cat $f >> ${LIP_IMAGE_FILE}
  p=$n
done

echo "All done."
echo
echo "Result can be found in:"
echo $PACK_INSTALL_DIR/
echo
