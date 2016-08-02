ISOURL=stable/18/linuxmint-18-mate-64bit.iso
SHA256=c634f48b248489eef782067484a04978f046e9ccd507d9df35c798a1db9bef22

install_live() {
	install -d "$KERNELDIR/mint/64" "$DATADIR/mint/64"
	cp "isofiles/$ISOFILE" "$DATADIR/mint/"
	mount_iso
	cp "$ISOMNT/casper/vmlinuz" "$ISOMNT/casper/initrd.lz" "$KERNELDIR/mint/64/"
	umount_iso
}

