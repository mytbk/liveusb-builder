install_live() {
	mount_iso
	install -d "$DATADIR/$KEYWORD" "$KERNELDIR/$KEYWORD"
	cp -r "$ISOMNT/sysresccd/x86_64" "$DATADIR/$KEYWORD/"
	cp -r "$ISOMNT/sysresccd/boot/x86_64" "$KERNELDIR/$KEYWORD/"
	cp "$ISOMNT/sysresccd/boot/"*.img "$KERNELDIR/$KEYWORD/"
	umount_iso
}
