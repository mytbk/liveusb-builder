install_live() {
	install -d "$KERNELDIR/debian/64" "$DATADIR/debian"
	cp "${ISO_FILEPATH}" "$DATADIR/debian/"
	mount_iso
	cp "$ISOMNT/live/vmlinuz"* "$ISOMNT/live/initrd.img"* "$KERNELDIR/debian/64/"
	umount_iso
}

