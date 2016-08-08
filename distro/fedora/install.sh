install_live() {
	mount_iso
	install -d "$DATADIR/fedora"
	cp "$ISOMNT/LiveOS"/* "$DATADIR/fedora/"
	install -d "$KERNELDIR/fedora"
	cp "$ISOMNT/isolinux/vmlinuz" "$ISOMNT/isolinux/initrd.img" "$KERNELDIR/fedora"
	umount_iso
}

