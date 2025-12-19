#!/bin/sh -e
. ./scripts/envsetup_pack.sh

KERNEL_BIN=$1

KIP_BIN=kernel.img
KIP_MAX_SIZE=67108864

[ "X${KERNEL_BIN}" != "X" ] || KERNEL_BIN=${PACK_OUTPUT_DIR}/linux/arch/${KERNEL_ARCH}/boot/Image
[ -e ${PACK_OUTPUT_DIR}/linux.bin ] || cp -p ${KERNEL_BIN} ${PACK_OUTPUT_DIR}/linux.bin
[ -e ${PACK_OUTPUT_DIR}/private.pem ] || cp -p ${GERNERAL_BIN}/imgsign/private.pem ${PACK_OUTPUT_DIR}/private.pem
[ -e ${PACK_OUTPUT_DIR}/public.pem ] || cp -p ${GERNERAL_BIN}/imgsign/public.pem ${PACK_OUTPUT_DIR}/public.pem

mkdir -p $PACK_INSTALL_DIR

rm -f ${PACK_OUTPUT_DIR}/linux_axgzip.bin
${GERNERAL_BIN}/ax_gzip -9 ${PACK_OUTPUT_DIR}/linux.bin

python3 ${GERNERAL_BIN}/imgsign/sec_boot_AX620E_sign.py -i ${PACK_OUTPUT_DIR}/linux_axgzip.bin \
	 -pub ${PACK_OUTPUT_DIR}/public.pem \
	 -prv ${PACK_OUTPUT_DIR}/private.pem -cap 0x54FAFE -key_bit 2048 -o ${PACK_INSTALL_DIR}/${KIP_BIN}

dd if=/dev/zero bs=${KIP_MAX_SIZE} count=1 | tr '\000' '\377' > ${PACK_INSTALL_DIR}/${KIP_BIN}.tmp
dd if=${PACK_INSTALL_DIR}/${KIP_BIN} of=${PACK_INSTALL_DIR}/${KIP_BIN}.tmp bs=${KIP_MAX_SIZE} count=1 conv=notrunc seek=0

echo OK
