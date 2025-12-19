#!/bin/sh -e
. ./scripts/envsetup_pack.sh

DEVICETREE_BIN=$1

[ "X${DEVICETREE_BIN}" != "X" ] || DEVICETREE_BIN=${PACK_OUTPUT_DIR}/linux/arch/${KERNEL_ARCH}/boot/dts/axera/${BOARD_DTS}.dtb
[ -e ${PACK_OUTPUT_DIR}/fdt.bin ] || cp -p ${DEVICETREE_BIN} ${PACK_OUTPUT_DIR}/fdt.bin
[ -e ${PACK_OUTPUT_DIR}/private.pem ] || cp -p ${GERNERAL_BIN}/imgsign/private.pem ${PACK_OUTPUT_DIR}/private.pem
[ -e ${PACK_OUTPUT_DIR}/public.pem ] || cp -p ${GERNERAL_BIN}/imgsign/public.pem ${PACK_OUTPUT_DIR}/public.pem

DTP_BIN=dtb.img
DTP_MAX_SIZE=1048576

mkdir -p $PACK_INSTALL_DIR

rm -f ${PACK_OUTPUT_DIR}/fdt_axgzip.bin
${GERNERAL_BIN}/ax_gzip -9 ${PACK_OUTPUT_DIR}/fdt.bin

python3 ${GERNERAL_BIN}/imgsign/sec_boot_AX620E_sign.py -i ${PACK_OUTPUT_DIR}/fdt_axgzip.bin \
	 -pub ${PACK_OUTPUT_DIR}/public.pem \
	 -prv ${PACK_OUTPUT_DIR}/private.pem -cap 0x54FAFE -key_bit 2048 -o ${PACK_INSTALL_DIR}/${DTP_BIN}

dd if=/dev/zero bs=${DTP_MAX_SIZE} count=1 | tr '\000' '\377' > ${PACK_INSTALL_DIR}/${DTP_BIN}.tmp
dd if=${PACK_INSTALL_DIR}/${DTP_BIN} of=${PACK_INSTALL_DIR}/${DTP_BIN}.tmp bs=${DTP_MAX_SIZE} count=1 conv=notrunc seek=0

echo OK
