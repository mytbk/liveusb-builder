install_live() {
	install -d "$KERNELDIR/trisquel/64" "$DATADIR/trisquel/64"
	cp "isofiles/$ISOFILE" "$DATADIR/trisquel/"
	mount_iso
	cp "$ISOMNT/casper/vmlinuz" "$ISOMNT/casper/initrd" "$KERNELDIR/trisquel/64/"
	umount_iso
}

