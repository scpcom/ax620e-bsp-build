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

m=$((51 * 1024))

if [ $b -le $m ]; then
  exit 1
fi

a=$(hexdump -s 16 -n 4 -e '"%d"' $PACKED_BIN)
b=$(($b - $m))

echo $b
if [ $a -le $b ]; then
  echo $a
  dd if=$PACKED_BIN of=${OUT_FILE}.fw.unsigned bs=1 skip=$m count=$a
else
  dd if=$PACKED_BIN of=${OUT_FILE}.fw.unsigned bs=1024 skip=51
fi

mv -v ${OUT_FILE}.fw.unsigned ${PACKED_BIN}.fw.unpacked
rm -f ${OUT_FILE}*

echo OK
