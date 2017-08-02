_name=garch/xfce
install_live() {
	mount_iso
	install -d "$DATADIR/$_name"
	install -d "$KERNELDIR/$_name"
	cp -r "$ISOMNT/arch/x86_64" "$DATADIR/$_name/"
	cp -r "$ISOMNT/arch/boot/x86_64" "$KERNELDIR/$_name/"
	cp "$ISOMNT/arch/boot/intel_ucode.img" "$KERNELDIR/$_name/"
	umount_iso
}

