#!/bin/sh -e
. ./scripts/envsetup_pack.sh

AXP_OUTPUT_DIR=$PACK_OUTPUT_DIR/axp
AXP_XML=${BOARD_BIN}/AX630C_emmc_arm64_k419.xml

mkdir -p "${AXP_OUTPUT_DIR}"

for f in ${BOARD_BIN}/AX630C_emmc_*.xml ; do
  [ -e $f ] || continue
  AXP_XML=$f
  cp -p "${AXP_XML}" "${AXP_OUTPUT_DIR}/"
  break
done

grep '<File>' "${AXP_XML}"  | cut -d '>' -f 2- | cut -d '<' -f 1 | while read f ; do
  e=none
  if echo $f | grep -q -E '^eip' ; then
    e=eip.bin
  elif echo $f | grep -q -E '^fdl2' ; then
    e=fdl2.bin
  elif echo $f | grep -q -E '^fdl_' ; then
    e=fdl.bin.tmp
  elif echo $f | grep -q -E '^spl' ; then
    e=spl.img.tmp
  elif echo $f | grep -q -E '^ddrinit' ; then
    e=ddrinit.img
  elif echo $f | grep -q -E '^atf' ; then
    e=atf.img
  elif echo $f | grep -q -E '^u-boot' ; then
    e=uboot.bin
  elif echo $f | grep -q -E 'logo\.bmp' ; then
    e=logo.img
  elif echo $f | grep -q -E '^optee' ; then
    e=optee.img
  elif echo $f | grep -q -E '\.dtb' ; then
    e=dtb.img
  elif echo $f | grep -q -E '^kernel|^boot_signed.bin' ; then
    e=kernel.img
  elif echo $f | grep -q -E 'bootfs.*fat' ; then
    e=bootfs.fat32
  elif echo $f | grep -q -E 'rootfs.*\.ext4' ; then
    e=rootfs_sparse.ext4
  fi
  if [ -e "$PACK_INSTALL_DIR/$e" ]; then
    cp -p "$PACK_INSTALL_DIR/$e" "${AXP_OUTPUT_DIR}/$f"
  else
    echo "Missing: $f ($e)"
  fi
done

echo OK
