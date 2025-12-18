#!/bin/sh -e
#GERNERAL_BIN=`pwd`/general_bin_ax630c
GERNERAL_BIN=`pwd`/axerabin/tools/bin
PACKED_BIN=$1

[ "X$PACKED_BIN" != "X" ] || exit 1

OUT_FILE=$(dirname ${PACKED_BIN})/copy-of-$(basename ${PACKED_BIN})
dd if=$PACKED_BIN of=${OUT_FILE}.unsigned bs=1024 skip=1

${GERNERAL_BIN}/ax_gzip -d ${OUT_FILE}.unsigned

mv -v ${OUT_FILE} ${PACKED_BIN}.unpacked
rm -f ${OUT_FILE}*

echo OK
