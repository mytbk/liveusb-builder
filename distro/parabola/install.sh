install_live() {
	mount_iso
	install -d "$DATADIR/parabola"
	cp -r "$ISOMNT/parabola/"{$ARCH,checksum*,pkglist*,aitab} "$DATADIR/parabola/"
	install -d "$KERNELDIR/parabola"
	cp -r "$ISOMNT/parabola/boot/$ARCH" "$KERNELDIR/parabola/"
	umount_iso
}

