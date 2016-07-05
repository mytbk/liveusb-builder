ISOURL=iso/2016.08.01/archlinux-2016.08.01-dual.iso
SHA1=6db5a9e46267ba7ec4d9ae79d141e5a6d9d3cf88

install_live() {
	mount_iso
	install -d "$DATADIR/arch"
	cp -r "$ISOMNT/arch/"{i686,x86_64} "$DATADIR/arch/"
	install -d "$KERNELDIR/arch"
	cp -r "$ISOMNT/arch/boot/"{i686,x86_64} "$KERNELDIR/arch/"
	cp "$ISOMNT/arch/boot/intel_ucode.img" "$KERNELDIR/arch/"
	umount_iso
}

