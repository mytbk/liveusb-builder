install_live() {
	install -d "$KERNELDIR/debian/64" "$DATADIR/debian"
	cp "$ISOPATH/$ISOFILE" "$DATADIR/debian/"
	mount_iso
	cp "$ISOMNT/live/vmlinuz" "$ISOMNT/live/initrd.img" "$KERNELDIR/debian/64/"
	umount_iso
}

