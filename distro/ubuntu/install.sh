install_live() {
	install -d "$KERNELDIR/ubuntu/${_ver}/64" "$DATADIR/ubuntu"
	cp "$ISOPATH/$ISOFILE" "$DATADIR/ubuntu/"
	mount_iso
	cp "$ISOMNT/casper/${VMLINUZ}" "$ISOMNT/casper/${INITRD}" "$KERNELDIR/ubuntu/${_ver}/64/"
	umount_iso
}
