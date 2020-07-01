install_live() {
	mount_iso
	install -d "$DATADIR/opensuse/" "$KERNELDIR/opensuse/$version"
	cp "$ISOMNT/boot/x86_64/loader"/{linux,initrd} \
		"$KERNELDIR/opensuse/$version"
	umount_iso
	cp "${ISO_FILEPATH}" "$DATADIR/opensuse/"
}
