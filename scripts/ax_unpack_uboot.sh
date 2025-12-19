#!/bin/sh -e
#GERNERAL_BIN=`pwd`/general_bin_ax630c
GERNERAL_BIN=`pwd`/axerabin/tools/bin
PACKED_BIN=$1

[ "X$PACKED_BIN" != "X" ] || exit 1

./scripts/ax_unpack_bin.sh $PACKED_BIN

echo OK
