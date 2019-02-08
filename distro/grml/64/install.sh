install_live() {
	install -d "$KERNELDIR/grml/64" "$DATADIR/grml"
	cp "$ISOPATH/$ISOFILE" "$DATADIR/grml/"
	mount_iso
	cp "$ISOMNT/boot/grml64full/vmlinuz" "$ISOMNT/boot/grml64full/initrd.img" "$KERNELDIR/grml/64/"
	umount_iso
}
