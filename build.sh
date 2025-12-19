#!/bin/sh -e
. ./scripts/envsetup_pack.sh

AX_BOARD_LINK=$BOARD_DTS

while [ "$#" -gt 0 ]; do
	case "$1" in
	--board=*|--board-link=*)
		export AX_BOARD_LINK=`echo $1 | cut -d '=' -f 2-`
		shift
		;;
	*)
		break
		;;
	esac
done

if [ "$AX_BOARD_LINK" != "$BOARD_DTS" ]; then
  sed -i s/'^BOARD_DTS=.*'/'BOARD_DTS='$AX_BOARD_LINK/g  ./scripts/envsetup_pack.sh
  . ./scripts/envsetup_pack.sh
fi

./scripts/get-toolchain.sh

./scripts/build-u-boot.sh
./scripts/build-linux.sh

./scripts/ax_pack_uboot.sh
./scripts/ax_pack_linux.sh
./scripts/ax_pack_dtb.sh

echo "All done."
echo
echo "Result can be found in:"
echo $PACK_INSTALL_DIR/
echo
