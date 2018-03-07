install_live() {
	install -d "$KERNELDIR/antix/32" "$DATADIR/antix"
	cp "isofiles/$ISOFILE" "$DATADIR/antix/"
	mount_iso
	cp "$ISOMNT/antiX/vmlinuz" "$ISOMNT/antiX/initrd.gz" "$KERNELDIR/antix/32/"
	umount_iso
}

