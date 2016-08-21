install_live() {
	mount_iso
	install -d "$KERNELDIR/void" "$DATADIR/void"
	cp "$ISOMNT/LiveOS"/* "$DATADIR/void/"
	cp "$ISOMNT/boot/vmlinuz" "$ISOMNT/boot/initrd" "$KERNELDIR/void"
	umount_iso
}
