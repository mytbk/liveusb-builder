ISOURL=releases/24/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-24-1.2.iso
SHA256=8e12d7ba1fcf3328b8514d627788ee0146c0eef75a5e27f0674ee1fe4f1feaf6

install_live() {
	mount_iso
	install -d "$DATADIR/fedora"
	cp "$ISOMNT/LiveOS"/* "$DATADIR/fedora/"
	install -d "$KERNELDIR/fedora"
	cp "$ISOMNT/isolinux/vmlinuz" "$ISOMNT/isolinux/initrd.img" "$KERNELDIR/fedora"
	umount_iso
}

