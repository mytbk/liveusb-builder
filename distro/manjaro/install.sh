install_live() {
	install -d "$DATADIR/manjaro/" "$KERNELDIR/manjaro"
	mount_iso
	cp "$ISOMNT/boot/vmlinuz-$ARCH" "$ISOMNT/boot/initramfs-$ARCH.img" "$ISOMNT/boot/intel_ucode.img" \
	       	"$KERNELDIR/manjaro"
	umount_iso
	cp "${ISO_FILEPATH}" "$DATADIR/manjaro/"
}

