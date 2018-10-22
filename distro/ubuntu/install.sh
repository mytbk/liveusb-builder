install_live() {
	install -d "$KERNELDIR/${KEYWORD}/${_ver}/64" "$DATADIR/${KEYWORD}"
	cp "$ISOPATH/$ISOFILE" "$DATADIR/${KEYWORD}/"
	mount_iso
	cp "$ISOMNT/casper/${VMLINUZ}" "$ISOMNT/casper/${INITRD}" "$KERNELDIR/${KEYWORD}/${_ver}/64/"
	umount_iso
}
