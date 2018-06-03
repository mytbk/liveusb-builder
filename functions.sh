# Copyright (C)  2016-2018 Iru Cai <mytbk920423@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

checksum_verify() {
	local _hashtool _hashsum _cksum
	if [ -n "$SHA512" ]; then
		_hashtool=sha512sum
		_hashsum=$SHA512
	elif [ -n "$SHA256" ]; then
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
	_cksum=$("$_hashtool" "$ISOPATH/$ISOFILE" | cut -d' ' -f1)
	if [[ $_cksum == $_hashsum ]]; then
		msg "$ISOFILE ok."
	else
		msg "$ISOFILE checksum bad!" && return 1
	fi
}

# process_isoinfo <iso, e.g. mint/64/xfce>
# loads $DISTRONAME $ISONAME $ISOFILE $ISOURL
process_isoinfo() {
	unset MD5 SHA1 SHA256 SHA512
	_distrobase="distro/$(cut -d'/' -f1 <<< "$1")"
	source "$_distrobase/distroinfo"
	source "distro/$1/isoinfo"
	ISOFILE="$(basename $ISOURL)"
}

process_distro() {
	source "distro/$1/install.sh"
	# FIXME
	# As a workaround, now we set $ISOFILE before using this function.
	# Maybe we have a better solution for this.
	ISOMNT="/media/$ISOFILE"
}

gen_grubcfg() {
	local entry allentries
	allentries=("distro/$1/entry"*)
	if [ ${#allentries[@]} -gt 1 ]; then
		echo "submenu '$ISONAME' {"
	fi
	for entry in "${allentries[@]}"
	do
		UUID="$UUID" ISOFILE="$ISOFILE" ./mkgrubcfg.sh "$entry"
	done
	if [ ${#allentries[@]} -gt 1 ]; then
		echo '}'
	fi
}

download_iso() {
	mkdir -p "$ISOPATH"
	for url in ${mirrorlist[@]}
	do
		wget -c -O "$ISOPATH/$ISOFILE" "$url/$ISOURL"
		if checksum_verify; then
			return 0
		else
			# checksum bad, may be due to a bad partial download
			# so remove the file and try again
			rm -f "$ISOPATH/$ISOFILE"
			wget -O "$ISOPATH/$ISOFILE" "$url/$ISOURL"
			checksum_verify && return 0
			rm -f "$ISOPATH/$ISOFILE" # then try next mirror
		fi
	done
	fatalerror "Fail to download $ISOFILE!"
}

mount_iso() {
	if findmnt "$ISOMNT" > /dev/null
	then
		umount_iso
	fi
	udevil mount "$ISOPATH/$ISOFILE" "$ISOMNT"
}

umount_iso() {
	udevil umount "$ISOMNT"
}

getuuid() {
	lsblk -n -o UUID "$1"
}

getdiskbypart() {
	# util-linux may have bug when using -s --raw
	# so it needs some work around
	local _devlist
	local _type
	_devlist=($(lsblk -s --raw -o NAME -n "$1"))
	for i in "${_devlist[@]}"
	do
		_type=$(lsblk -o TYPE -n "/dev/$i" | head -n1)
		if [[ "$_type" == "disk" ]]; then
			echo $i
		fi
	done
}

as-root() {
	echo as-root "$*"
	if [ "$UID" == 0 ]; then
		"$@"
	elif type -p sudo > /dev/null; then
		sudo "$@"
	elif type -p su > /dev/null; then
		su -c "$*"
	fi
}
