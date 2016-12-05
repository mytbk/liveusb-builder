install_live() {
	mount_iso
	install -d "$DATADIR/fedora/$version" "$KERNELDIR/fedora/$version"
	cp "$ISOMNT/LiveOS"/* "$DATADIR/fedora/$version"
	cp "$ISOMNT/isolinux/vmlinuz" "$ISOMNT/isolinux/initrd.img" "$KERNELDIR/fedora/$version"
	umount_iso
}

