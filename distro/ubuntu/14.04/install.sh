install_live() {
	install -d "$KERNELDIR/ubuntu/14.04/64" "$DATADIR/ubuntu"
	cp "${ISO_FILEPATH}" "$DATADIR/ubuntu/"
	mount_iso
	cp "$ISOMNT/casper/vmlinuz.efi" "$ISOMNT/casper/initrd.lz" "$KERNELDIR/ubuntu/14.04/64/"
	umount_iso
}

