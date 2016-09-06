install_live() {
	mount_iso
	install -d "$KERNELDIR/parabola" "$DATADIR/parabola/mate"
	cp -r "$ISOMNT/parabola/"{i686,x86_64,checksum*,pkglist*,aitab} "$DATADIR/parabola/mate"
	cp -r "$ISOMNT/parabola/boot/"{i686,x86_64} "$KERNELDIR/parabola/"
	umount_iso
}

