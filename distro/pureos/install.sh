install_live() {
	install -d "$KERNELDIR/pureos" "$DATADIR/pureos"
	mount_iso
	cp "$ISOMNT/casper/vmlinuz" "$ISOMNT/casper/initrd.img" \
		"$KERNELDIR/pureos"
	install -m600 "$ISOMNT/casper/filesystem.squashfs" "$DATADIR/pureos"
	umount_iso
}
