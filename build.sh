#!/bin/sh -e
. ./scripts/envsetup_pack.sh

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
