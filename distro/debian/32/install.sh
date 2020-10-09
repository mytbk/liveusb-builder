install_live() {
	install -d "$KERNELDIR/debian/32" "$DATADIR/debian"
	cp "${ISO_FILEPATH}" "$DATADIR/debian/"
	mount_iso
	cp "$ISOMNT/live/vmlinuz"* "$ISOMNT/live/initrd.img"* "$KERNELDIR/debian/32/"
	umount_iso
}
