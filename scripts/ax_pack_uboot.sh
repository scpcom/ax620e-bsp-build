#!/bin/sh -e
. ./scripts/envsetup_pack.sh

UBOOT_BIN=$1

UIP_BIN=uboot.bin
UIP_MAX_SIZE=1572864

[ "X${UBOOT_BIN}" != "X" ] || UBOOT_BIN=${PACK_OUTPUT_DIR}/u-boot/u-boot.bin
[ -e ${PACK_OUTPUT_DIR}/u-boot.bin ] || cp -p ${UBOOT_BIN} ${PACK_OUTPUT_DIR}/u-boot.bin
[ -e ${PACK_OUTPUT_DIR}/private.pem ] || cp -p ${GERNERAL_BIN}/imgsign/private.pem ${PACK_OUTPUT_DIR}/private.pem
[ -e ${PACK_OUTPUT_DIR}/public.pem ] || cp -p ${GERNERAL_BIN}/imgsign/public.pem ${PACK_OUTPUT_DIR}/public.pem

mkdir -p $PACK_INSTALL_DIR

rm -f ${PACK_OUTPUT_DIR}/u-boot_axgzip.bin
${GERNERAL_BIN}/ax_gzip -9 ${PACK_OUTPUT_DIR}/u-boot.bin

python3 ${GERNERAL_BIN}/imgsign/sec_boot_AX620E_sign.py -i ${PACK_OUTPUT_DIR}/u-boot_axgzip.bin \
	 -pub ${PACK_OUTPUT_DIR}/public.pem \
	 -prv ${PACK_OUTPUT_DIR}/private.pem -cap 0x54FAFE -key_bit 2048 -o ${PACK_INSTALL_DIR}/${UIP_BIN}

dd if=/dev/zero bs=${UIP_MAX_SIZE} count=1 | tr '\000' '\377' > ${PACK_INSTALL_DIR}/${UIP_BIN}.tmp
dd if=${PACK_INSTALL_DIR}/${UIP_BIN} of=${PACK_INSTALL_DIR}/${UIP_BIN}.tmp bs=${UIP_MAX_SIZE} count=1 conv=notrunc seek=0

echo OK
