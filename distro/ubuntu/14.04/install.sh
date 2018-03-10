install_live() {
	install -d "$KERNELDIR/ubuntu/14.04/64" "$DATADIR/ubuntu"
	cp "$ISOPATH/$ISOFILE" "$DATADIR/ubuntu/"
	mount_iso
	cp "$ISOMNT/casper/vmlinuz.efi" "$ISOMNT/casper/initrd.lz" "$KERNELDIR/ubuntu/14.04/64/"
	umount_iso
}

