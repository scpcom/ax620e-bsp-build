#!/bin/sh -e
GERNERAL_BIN=`pwd`/axerabin/tools/bin
image=$1

blkdevparts="
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

if [ -e ./scripts/envsetup_pack.sh ]; then
  . ./scripts/envsetup_pack.sh
fi

[ "X$image" != "X" ] || exit 1
[ -e $image ] || exit 1

base=$(dirname $image)
[ "X$base" = "X" ] || base=$base/
base=$base$(basename $image | cut -d '.' -f 1)
loader=$base-loader.bin

o=0
for part in $blkdevparts ; do
  s=$(echo $part | cut -d '(' -f 1)
  if echo $s | grep -q M ; then
    k=$(echo $s | sed s/'M$'/''/g)
    k=$(($k * 1024))
  else
    k=$(echo $s | sed s/'K$'/''/g)
  fi
  o=$(($o + k))
done

echo 0 $o $(basename $loader)
if [ -e $loader ]; then
  true
elif file $image | grep -q 'XZ compressed' ; then
  xz -cd $image | dd of=$loader bs=1024 count=$o
else
  dd if=$image of=$loader bs=1024 count=$o
fi

mkdir -p $base-dump

o=0
for part in $blkdevparts ; do
  s=$(echo $part | cut -d '(' -f 1)
  n=$(echo $part | cut -d '(' -f 2 | cut -d ')' -f 1)
  if echo $s | grep -q M ; then
    k=$(echo $s | sed s/'M$'/''/g)
    k=$(($k * 1024))
  else
    k=$(echo $s | sed s/'K$'/''/g)
  fi
  echo $o $k $n.bin
  f=$base-dump/$n.bin
  if [ -e $f.unpacked ]; then
    o=$(($o + k))
    continue
  fi
  dd if=$loader of=$f bs=1024 skip=$o count=$k
  if echo $n | grep -q -E '^boot|^env|^logo' ; then
    if file $f | grep -q 'PC bitmap' ; then
      a=$(hexdump -s 2 -n 4 -e '"%d"' $f)
      b=$(($k * 1024))
      if [ $a -le $b ]; then
        echo copy $a bytes
        dd if=$f of=$f.unpacked bs=1 count=$a
      else
        echo copy
        cp -p $f $f.unpacked
      fi
    else
      echo copy
      cp -p $f $f.unpacked
    fi
  else
    a=$(hexdump -s 12 -n 4 -e '"%d"' $f)
    b=$(($k * 1024))
    if [ $a -le $b ]; then
      echo unsign $a bytes
      dd if=$f of=$f.unsigned bs=1 skip=1024 count=$a
    else
      echo unsign
      dd if=$f of=$f.unsigned bs=1024 skip=1
    fi
    if echo $n | grep -q -E '^fdl|^ddrinit|^spl' ; then
      mv $f.unsigned $f.unpacked
    else
      echo unpack
      g=$base-dump/copy-of-$n.bin
      mv $f.unsigned $g.unsigned
      ${GERNERAL_BIN}/ax_gzip -d $g.unsigned
      mv $g $f.unpacked
      rm -f $g.unsigned*
    fi
  fi
  if echo $n | grep -q -E '^kernel' ; then
    if [ -e ./scripts/repack-zImage.sh ]; then
      ./scripts/repack-zImage.sh -u $f.unpacked

      cp -p $f.unpacked_unpacked/initramfs.cpio $f.initramfs_rootfs.cpio
      rm -rf $f.unpacked_unpacked/
    fi
  fi
  o=$(($o + k))
done

if [ "X${PACK_OUTPUT_DIR}" != "X" -a "X${PACK_INSTALL_DIR}" != "X" ]; then
  DUMP_OUTPUT_DIR=$base-dump
  mkdir -p ${PACK_OUTPUT_DIR}
  [ ! -e ${DUMP_OUTPUT_DIR}/boot.bin.unpacked ] || cp -p ${DUMP_OUTPUT_DIR}/boot.bin.unpacked ${PACK_OUTPUT_DIR}/fdl.bin
  cp -p ${DUMP_OUTPUT_DIR}/atf.bin.unpacked ${PACK_OUTPUT_DIR}/atf.bin
  cp -p ${DUMP_OUTPUT_DIR}/optee.bin.unpacked ${PACK_OUTPUT_DIR}/optee.bin
  cp -p ${DUMP_OUTPUT_DIR}/spl.bin.unpacked ${PACK_OUTPUT_DIR}/spl.bin
  cp -p ${DUMP_OUTPUT_DIR}/logo.bin.unpacked ${PACK_OUTPUT_DIR}/logo.bmp
  cp -p ${DUMP_OUTPUT_DIR}/ddrinit.bin.unpacked ${PACK_OUTPUT_DIR}/ddrinit.bin
  mkdir -p ${PACK_INSTALL_DIR}
  cp -p ${DUMP_OUTPUT_DIR}/kernel.bin.initramfs_rootfs.cpio ${PACK_INSTALL_DIR}/initramfs_rootfs.cpio
fi

echo OK
