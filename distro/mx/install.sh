install_live() {
	install -d "$KERNELDIR/$KEYWORD/$BITS" "$DATADIR/$KEYWORD"
	cp "$ISOPATH/$ISOFILE" "$DATADIR/$KEYWORD/"
	mount_iso
	cp "$ISOMNT/antiX/vmlinuz" "$ISOMNT/antiX/initrd.gz" \
		"$KERNELDIR/$KEYWORD/$BITS/"
	umount_iso
}
