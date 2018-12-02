install_live() {
	mount_iso
	install -d "$DATADIR/$KEYWORD" "$KERNELDIR/$KEYWORD"
	cp -r "$ISOMNT/arch/x86_64" "$DATADIR/$KEYWORD/"
	cp -r "$ISOMNT/arch/boot/x86_64" "$KERNELDIR/$KEYWORD/"
	cp "$ISOMNT/arch/boot/"*.img "$KERNELDIR/$KEYWORD/"
	umount_iso
}

