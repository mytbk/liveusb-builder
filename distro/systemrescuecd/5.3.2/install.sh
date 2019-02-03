install_live() {
	mount_iso
	install -d "$DATADIR/sysrcd" "$KERNELDIR/sysrcd"
	cp "$ISOMNT/"{sysrcd.dat,sysrcd.md5} "$DATADIR/sysrcd/"
	cp "$ISOMNT/isolinux/"{rescue32,rescue64,initram.igz} "$KERNELDIR/sysrcd/"
	umount_iso
}
