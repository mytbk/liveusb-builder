install_live() {
	mount_iso
	install -d "$DATADIR/$KEYWORD" "$KERNELDIR/$KEYWORD"
	cp "$ISOPATH/$ISOFILE" "$DATADIR/$KEYWORD/"
	cp "$ISOMNT/live/"{vmlinuz,initrd.lz} "$KERNELDIR/$KEYWORD/"
	umount_iso
}
