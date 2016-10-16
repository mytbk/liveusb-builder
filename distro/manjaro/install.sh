install_live() {
	install -d "$DATADIR/manjaro/" "$KERNELDIR/manjaro"
	mount_iso
	cp -r "$ISOMNT/manjaro/boot/$ARCH" "$ISOMNT/manjaro/boot/intel_ucode.img" \
	       	"$KERNELDIR/manjaro"
	umount_iso
        cp "isofiles/$ISOFILE" "$DATADIR/manjaro/"
}

