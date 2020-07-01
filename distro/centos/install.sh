install_live() {
	mount_iso
	install -d "$DATADIR/centos/" "$KERNELDIR/centos/$version"
	cp "${ISO_FILEPATH}" "$DATADIR/centos/"
	cp "$ISOMNT/images/pxeboot/vmlinuz" "$ISOMNT/images/pxeboot/initrd.img" "$KERNELDIR/centos/$version"
	umount_iso
}

