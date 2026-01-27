#!/bin/sh -e
. ./scripts/envsetup_pack.sh

IN_FILE=$1
IN_FW=$2
PACKED_BIN=$3
PACKED_MAX_SIZE=$4
EXTRA_PARAM=$5

[ "X${IN_FILE}" != "X" ] || exit 1
[ "X${IN_FW}" != "X" ] || exit 1

INPUT_BIN=$(basename ${IN_FILE})
INPUT_FW=$(basename ${IN_FW})

[ "X${PACKED_BIN}" != "X" ] || PACKED_BIN=${INPUT_BIN}
[ "X${PACKED_MAX_SIZE}" != "X" ] || PACKED_MAX_SIZE=67108864

[ -e ${PACK_OUTPUT_DIR}/${INPUT_BIN} ] || cp -p ${IN_FILE} ${PACK_OUTPUT_DIR}/${INPUT_BIN}
[ -e ${PACK_OUTPUT_DIR}/${INPUT_FW} ] || cp -p ${IN_FW} ${PACK_OUTPUT_DIR}/${INPUT_FW}
[ -e ${PACK_OUTPUT_DIR}/private.pem ] || cp -p ${GERNERAL_BIN}/imgsign/private.pem ${PACK_OUTPUT_DIR}/private.pem
[ -e ${PACK_OUTPUT_DIR}/public.pem ] || cp -p ${GERNERAL_BIN}/imgsign/public.pem ${PACK_OUTPUT_DIR}/public.pem

mkdir -p $PACK_INSTALL_DIR

python3 ${GERNERAL_BIN}/imgsign/spl_AX620E_sign.py -i ${PACK_OUTPUT_DIR}/${INPUT_BIN} -fw ${PACK_OUTPUT_DIR}/${INPUT_FW} \
	 -pub ${PACK_OUTPUT_DIR}/public.pem \
	 -prv ${PACK_OUTPUT_DIR}/private.pem -cap 0x54FAFE -key_bit 2048 -o ${PACK_INSTALL_DIR}/${PACKED_BIN} $EXTRA_PARAM

if [ "${PACKED_MAX_SIZE}" = "-" ]; then
  dd if=${PACK_INSTALL_DIR}/${PACKED_BIN} of=${PACK_INSTALL_DIR}/${PACKED_BIN}.tmp conv=notrunc
else
  dd if=/dev/zero bs=${PACKED_MAX_SIZE} count=1 | tr '\000' '\377' > ${PACK_INSTALL_DIR}/${PACKED_BIN}.tmp
  dd if=${PACK_INSTALL_DIR}/${PACKED_BIN} of=${PACK_INSTALL_DIR}/${PACKED_BIN}.tmp bs=${PACKED_MAX_SIZE} count=1 conv=notrunc seek=0
fi

echo OK
