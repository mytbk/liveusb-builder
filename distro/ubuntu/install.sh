install_live() {
	install -d "$KERNELDIR/ubuntu/64" "$DATADIR/ubuntu/64"
	cp "isofiles/$ISOFILE" "$DATADIR/ubuntu/"
	mount_iso
	cp "$ISOMNT/casper/vmlinuz.efi" "$ISOMNT/casper/initrd.lz" "$KERNELDIR/ubuntu/64/"
	umount_iso
}

