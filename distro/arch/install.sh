ISOURL=iso/2016.08.01/archlinux-2016.08.01-dual.iso
SHA1=6db5a9e46267ba7ec4d9ae79d141e5a6d9d3cf88

install() {
	mount_iso
	umount_iso
}

