install_live() {
	mount_iso
	install -d "$DATADIR/hyperbola"
	cp -r "$ISOMNT/hyperbola/"{aitab,i686,x86_64} "$DATADIR/hyperbola/"
	install -d "$KERNELDIR/hyperbola"
	cp -r "$ISOMNT/hyperbola/boot" "$KERNELDIR/hyperbola"
	umount_iso
}
