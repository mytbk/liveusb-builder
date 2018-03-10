install_live() {
	install -d "$KERNELDIR/mint/64" "$DATADIR/mint"
	cp "$ISOPATH/$ISOFILE" "$DATADIR/mint/"
	mount_iso
	cp "$ISOMNT/casper/vmlinuz" "$ISOMNT/casper/initrd.lz" "$KERNELDIR/mint/64/"
	umount_iso
}

