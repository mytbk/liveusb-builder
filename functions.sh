# Copyright (C)  2016-2018 Iru Cai <mytbk920423@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

msg() {
	echo -e "$1" >&2
}

fatalerror() {
	msg "\x1b[1;31m$1\x1b[0m"
	exit 1
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

# output_grub_entry
# output_syslinux_entry
# usage: first source the entry, then call this
#
# variables in entryfile:
# - UUID: the UUID of the partition
# - ISOFILE: the file name of iso
#
# parameters in entry file:
# - TITLE: GRUB menu entry title
# - KERNEL: path to kernel image
# - INITRD: path to initramfs/initrd image
# - OPTION: kernel command line
# - X64: y/n, indicates whether it's 64-bit
#
output_grub_entry() {
	cat << EOF
menuentry '$TITLE' {
	linux $KERNEL $OPTION
	initrd ${INITRD[@]}
}

EOF
}

# we also need $LABEL when calling this
output_syslinux_entry() {
	_INITRD=$(echo ${INITRD[*]}|sed 's/ /,/g')

	cat << EOF
LABEL $LABEL
MENU LABEL $TITLE
LINUX $KERNEL
INITRD $_INITRD
APPEND $OPTION

EOF
}

gen_grubcfg() {
	local entry allentries
	allentries=("distro/$1/entry"*)
	if [ ${#allentries[@]} -gt 1 ]; then
		echo "submenu '$ISONAME' {"
	fi
	for entry in "${allentries[@]}"
	do
		unset INITRD # because it can be an array or just a string

		source "$entry"
		UUID="$UUID" ISOFILE="$ISOFILE" output_grub_entry
	done
	if [ ${#allentries[@]} -gt 1 ]; then
		echo '}'
	fi
}

meta_gen_grubcfg() {
	local entry
	source "distro/$1/meta"
	if [ ${#entries[@]} -gt 1 ]; then
		echo "submenu '$ISONAME' {"
	fi
	for entry in "${entries[@]}"
	do
		unset INITRD # because it can be an array or just a string

		"$entry"
		UUID="$UUID" ISOFILE="$ISOFILE" output_grub_entry
	done
	if [ ${#entries[@]} -gt 1 ]; then
		echo '}'
	fi
}

meta_gen_syslinux() {
	local entry count name
	source "distro/$1/meta"
	name=$(echo $1|sed 's/\//_/g')
	count=0
	for entry in "${entries[@]}"
	do
		unset INITRD # because it can be an array or just a string

		"$entry"
		UUID="$UUID" ISOFILE="$ISOFILE" LABEL="${name}_${count}" \
			output_syslinux_entry
		count=$(($count+1))
	done
}

gen_syslinux() {
	local entry allentries count name
	allentries=("distro/$1/entry"*)
	name=$(echo $1|sed 's/\//_/g')
	count=0
	for entry in "${allentries[@]}"
	do
		unset INITRD # because it can be an array or just a string

		source "$entry"
		UUID="$UUID" ISOFILE="$ISOFILE" LABEL="${name}_${count}" \
			output_syslinux_entry
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

get_iso_label() {
	# the label of an ISO file is between two quote symbols
	# of the file(1) output
	file -b "$1" | cut -d\' -f2
}

# We try to a proper mount tool to mount block devices and iso files,
# if we cannot find it, use the system mount tool.
# Both udisks2 and udevil can mount block devices, but only udevil
# can mount iso files.
detect_block_mount_tool() {
       if (udisksctl status | grep DEVICE > /dev/null); then
	       BLOCKMOUNT=udisks2
       elif (udevil | grep 'udevil version' > /dev/null); then
	       BLOCKMOUNT=udevil
       else
	       BLOCKMOUNT=system
       fi
}

detect_iso_mount_tool() {
       if (udevil | grep 'udevil version' > /dev/null); then
	       ISOMOUNT=udevil
       else
	       ISOMOUNT=system
       fi
}

udevil_mount() {
	udevil mount "$1"
}

udevil_unmount() {
	udevil umount "$1"
}

udisks2_mount() {
	udisksctl mount -b "$1"
}

udisks2_unmount() {
	local mnt_source
	mnt_source="$(findmnt -n -o SOURCE "$1")"
	udisksctl unmount -b "${mnt_source}"
}

system_mount() {
	local mountpoint
	local uid
	mountpoint="$(mktemp -d)"
	uid="$(id -u)"
	# first try uid= option of mount(1)
	if ! as-root mount -o "uid=$uid" "$1" "$mountpoint" 2> /dev/null; then
		as-root mount "$1" "$mountpoint"
	fi
}

system_unmount() {
	as-root umount "$1"
}

mount_block() {
	${BLOCKMOUNT}_mount "$1"
}

unmount_block() {
	${BLOCKMOUNT}_unmount "$1"
}

mount_iso() {
	LOOPDEV=$(/sbin/losetup -n -O NAME -j "${ISO_FILEPATH}")
	if [[ -n "$LOOPDEV" ]]
	then
		ISOMNT="$LOOPDEV"
		umount_iso
	fi

	${ISOMOUNT}_mount "${ISO_FILEPATH}"
	LOOPDEV=$(/sbin/losetup -n -O NAME -j "${ISO_FILEPATH}")
	if [[ -n "$LOOPDEV" ]]
	then
		ISOMNT=$(findmnt -n -o TARGET "$LOOPDEV")
	fi
}

umount_iso() {
	${ISOMOUNT}_unmount "$ISOMNT"
}

# iso_extract: extract files from iso image to destination path
# usage: iso_extract <isofile> <patterns> <dest>
iso_extract() {
	local isofile="$1"
	local patterns=()
	shift
	while [ "$#" -gt 1 ]; do
		patterns+=("$1")
		shift
	done
	local dest="$1"
	bsdtar -x -f "$isofile" -C "$dest" "${patterns[@]}"
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

syslinux_header() {
	cat << EOF
UI menu.c32

TIMEOUT 50

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
		cat  << 'EOF'
set default=0
set timeout=5

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
}
