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
	elif [ -n "$VERIFY" ]; then
		"$VERIFY" && return 0 || return 1
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

# a hash verify function that uses a checksum file
# usage: set HASHTOOL and HASHFILE in isoinfo, set VERIFY as hashfile
hashfile() {
	local _cksum _hashsum
	_cksum=$("$HASHTOOL" "$ISOPATH/$ISOFILE" | cut -d' ' -f1)
	_hashsum=$(grep "${ISOFILE}\$" "$HASHFILE" | cut -d' ' -f1)

	if [[ $_cksum == $_hashsum ]]; then
		msg "$ISOFILE ok."
	else
		msg "$ISOFILE checksum bad!" && return 1
	fi
}

set_distro() {
	_distrobase="distro/$(cut -d'/' -f1 <<< "$1")"
	source "$_distrobase/distroinfo"
}

# process_isoinfo <iso, e.g. mint/64/xfce>
# loads $DISTRONAME $ISONAME $ISOFILE $ISOURL
process_isoinfo() {
	unset MD5 SHA1 SHA256 SHA512
	set_distro "$1"
	source "distro/$1/isoinfo"
	ISOFILE="$(basename $ISOURL)"
}

process_distro() {
	source "distro/$1/install.sh"
	# FIXME
	# As a workaround, now we set $ISOFILE before using this function.
	# Maybe we have a better solution for this.
	# ISOMNT="/media/$ISOFILE"
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

gen_syslinux() {
	local entry allentries count name
	allentries=("distro/$1/entry"*)
	name=$(echo $1|sed 's/\//_/g')
	count=0
	for entry in "${allentries[@]}"
	do
		UUID="$UUID" ISOFILE="$ISOFILE" LABEL="$name$count" \
			./mksyslinux.sh "$entry"
		count=$(($count+1))
	done
}

download_iso() {
	mkdir -p "$ISOPATH"
	for url in ${mirrorlist[@]}
	do
		if wget -c -O "$ISOPATH/$ISOFILE" "$url/$ISOURL"; then
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
		fi
	done
	fatalerror "Fail to download $ISOFILE!"
}

mount_iso() {
	LOOPDEV=$(/sbin/losetup -n -O NAME -j "$ISOPATH/$ISOFILE")
	if [[ -n "$LOOPDEV" ]]
	then
		ISOMNT="$LOOPDEV"
		umount_iso
	fi

	udevil mount "$ISOPATH/$ISOFILE"
	LOOPDEV=$(/sbin/losetup -n -O NAME -j "$ISOPATH/$ISOFILE")
	if [[ -n "$LOOPDEV" ]]
	then
		ISOMNT=$(findmnt -n -o TARGET "$LOOPDEV")
	fi
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

syslinux_header() {
	cat << EOF
UI menu.c32

MENU TITLE Live USB
MENU COLOR border       30;44   #40ffffff #a0000000 std
MENU COLOR title        1;36;44 #9033ccff #a0000000 std
MENU COLOR sel          7;37;40 #e0ffffff #20ffffff all
MENU COLOR unsel        37;44   #50ffffff #a0000000 std
MENU COLOR help         37;40   #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40   #80ffffff #00000000 std
MENU COLOR timeout      1;37;40 #c0ffffff #00000000 std
MENU COLOR msg07        37;40   #90ffffff #a0000000 std
MENU COLOR tabmsg       31;40   #30ffffff #00000000 std

EOF
}

grubcfg_header() {
	echo '# The live USB grub.cfg file'

	if [ -z "$TXTMODE" ]; then
		cat  << 'EOF'
if [ ${grub_platform} == efi ]; then
	insmod all_video
	insmod font
	if loadfont /grub/fonts/unicode.pf2; then
		insmod gfxterm
		set gfxmode=auto
		set gfxpayload=keep
		terminal_output gfxterm
	fi
fi

EOF
	fi
}
