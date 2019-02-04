install_live() {
	install -d "$KERNELDIR/mint/lmde/64" "$DATADIR/mint"
	mount_iso
	cp "$ISOMNT/live/vmlinuz" "$ISOMNT/live/initrd.lz" "$KERNELDIR/mint/lmde/64/"
	cp "$ISOPATH/$ISOFILE" "$DATADIR/mint/"
	umount_iso
}
