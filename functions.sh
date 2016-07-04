process_distro() {
	source "distro/$1/install.sh"
	ISOFILE="$(basename $ISOURL)"
	ISOMNT="/media/$ISOFILE"
}

mount_iso() {
	udevil mount "isofiles/$ISOFILE" "$ISOMNT"
}

umount_iso() {
	udevil umount "$ISOMNT"
}

getuuid() {
	lsblk -n -o UUID "$1"
}
