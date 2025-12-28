#!/bin/sh -e
. ./scripts/envsetup_pack.sh

RAMFS_OUTPUT_DIR=$PACK_OUTPUT_DIR/ramfs

reorderInitramfsList(){
    # This is some black magic to get about the same compression
    # result as the original initramfs.cpio.  We reorder the files in
    # our initramfs (which is to be created) so that they appear in
    # the same order as in the original initramfs.
    #
    # Syntax: reorderInitramfsList <initramfs_list_file> <reordering_template_file>
    #
    # Reorders <initramfs_list_file> so that enries are in the order
    # given by <reordering_template_file> (which comes from cpio -t).
    # Files in <initramfs_list_file> but not in
    # <reordering_template_file> are moved in sorted order to the end.
    # Comments and empty lines are discarded.  The result is written
    # to <initramfs_list_file>.

    #echo >&2 "Reordering initramfs list"
    initramfs_list_file="$1"
    reordering_template_file="$2"
    declare -A ramfs_entries    # make it an associative array
    while read line; do
        set -- $line
        [ $# -eq 0 ] && continue # skip empty lines
        [[ "$1" = \#* ]] && continue # skip comments
        ramfs_entries["$2"]="$line"  # else remember line, indexed by path
    done < "$initramfs_list_file"
    echo "# reordered ramfs entries" > "$initramfs_list_file"
    # now spit the lines out in the order given by the reordering_template_file:
    while read path; do
        echo "${ramfs_entries["$path"]}"
        unset ramfs_entries["$path"] # remove written lines from the array
    done < "$reordering_template_file" >> "$initramfs_list_file"
    # if there are any files left, append them in sorted order so directories
    # come first:
    for line in "${ramfs_entries[@]}"; do
        echo "$line"
    done \
    | sort >> "$initramfs_list_file"
}

if [ -e ${PACK_INSTALL_DIR}/initramfs_rootfs.cpio -a ! -e ${PACK_OUTPUT_DIR}/initramfs_rootfs.cpio ]; then
  cp -p ${PACK_INSTALL_DIR}/initramfs_rootfs.cpio ${PACK_OUTPUT_DIR}/initramfs_rootfs.cpio
fi

[ ${PACK_OUTPUT_DIR}/initramfs_rootfs.cpio ] || exit 1

mkdir -p "$RAMFS_OUTPUT_DIR"

cpio -t < "${PACK_OUTPUT_DIR}/initramfs_rootfs.cpio" > "$PACK_OUTPUT_DIR/cpio_t-list.txt"
cd "$RAMFS_OUTPUT_DIR"
cpio -i -m --no-absolute-filenames -d -u < "${PACK_OUTPUT_DIR}/initramfs_rootfs.cpio"
cd - > /dev/null

# add ramfs modifications here

./linux/usr/gen_initramfs_list.sh -u squash -g squash "$RAMFS_OUTPUT_DIR" > "$PACK_OUTPUT_DIR/ramfs-list.txt"
cp "$PACK_OUTPUT_DIR/ramfs-list.txt" "$PACK_OUTPUT_DIR/ramfs-list.txt.orig"

reorderInitramfsList "$PACK_OUTPUT_DIR/ramfs-list.txt" "$PACK_OUTPUT_DIR/cpio_t-list.txt"

# No gen_init_cpio:  Use our own cpio routine
(
    cd "$RAMFS_OUTPUT_DIR"
    # extract the file names from our
    # (possibly reordered) initramfs list
    # and pass them to cpio:
    while read line; do
        set -- $line
        [ $# -eq 0 ] && continue # skip empty lines
        [[ "$1" = \#* ]] && continue # skip comments
        echo "${2#/}"
    done < "$PACK_OUTPUT_DIR/ramfs-list.txt" \
    | cpio -H newc -R root:root -o  > "${PACK_INSTALL_DIR}/initramfs_rootfs.cpio"
)

echo OK
