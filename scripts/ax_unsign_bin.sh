#!/bin/sh -e
#GERNERAL_BIN=`pwd`/general_bin_ax630c
GERNERAL_BIN=`pwd`/axerabin/tools/bin
PACKED_BIN=$1

[ "X$PACKED_BIN" != "X" ] || exit 1

OUT_FILE=$(dirname ${PACKED_BIN})/copy-of-$(basename ${PACKED_BIN})

a=$(hexdump -s 12 -n 4 -e '"%d"' $PACKED_BIN)
b=`stat -c %s $PACKED_BIN`

if [ $a -le $b ]; then
  dd if=$PACKED_BIN of=${OUT_FILE}.unsigned bs=1 skip=1024 count=$a
else
  dd if=$PACKED_BIN of=${OUT_FILE}.unsigned bs=1024 skip=1
fi

mv -v ${OUT_FILE}.unsigned ${PACKED_BIN}.unpacked
rm -f ${OUT_FILE}*

echo OK
