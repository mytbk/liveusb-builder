install_live() {
	mount_iso
	install -d "$DATADIR/arch"
	cp -r "$ISOMNT/arch/"{i686,x86_64} "$DATADIR/arch/"
	install -d "$KERNELDIR/arch"
	cp -r "$ISOMNT/arch/boot/"{i686,x86_64} "$KERNELDIR/arch/"
	cp "$ISOMNT/arch/boot/intel_ucode.img" "$KERNELDIR/arch/"
	umount_iso
}

