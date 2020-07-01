install_live() {
	mount_iso
	install -d "$DATADIR/$KEYWORD" "$KERNELDIR/$KEYWORD"
	cp "${ISO_FILEPATH}" "$DATADIR/$KEYWORD/"
	cp "$ISOMNT/live/"{vmlinuz,initrd.lz} "$KERNELDIR/$KEYWORD/"
	umount_iso
}
