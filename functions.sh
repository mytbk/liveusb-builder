checksum_verify() {
	local _hashtool _hashsum _cksum
	if [ -n "$SHA256" ]; then
		_hashtool=sha256sum
		_hashsum=$SHA256
	elif [ -n "$SHA1" ]; then
		_hashtool=sha1sum
		_hashsum=$SHA1
	elif [ -n "$MD5" ]; then
		_hashtool=md5sum
		_hashsum=$MD5
	else
		fatalerror "Cannot find the SHA256, SHA1, or MD5 checksum of $ISOFILE"
	fi
	_cksum=$("$_hashtool" "isofiles/$ISOFILE" | cut -d' ' -f1)
	if [[ $_cksum == $_hashsum ]]; then
		msg "$ISOFILE ok."
	else
		fatalerror "$ISOFILE checksum bad!"
	fi
}

process_distro() {
	unset MD5 SHA1 SHA256
	source "distro/$1/install.sh"
	ISOFILE="$(basename $ISOURL)"
	ISOMNT="/media/$ISOFILE"
	MIRRORLIST=(`cat "distro/$1/mirrorlist"`)
}

download_iso() {
	mkdir -p isofiles
	for url in ${MIRRORLIST[@]}
	do
		wget -O "isofiles/$ISOFILE" "$url/$ISOURL" && return 0
	done
	fatalerror "Fail to download $ISOFILE!"
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

as-root() {
	if [ "$UID" == 0 ]; then
		"$@"
	elif type -p sudo > /dev/null; then
		sudo "$@"
	elif type -p su > /dev/null; then
		su -c "$*"
	fi
}
