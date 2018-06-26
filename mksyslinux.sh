# Copyright (C)  2018 Iru Cai <mytbk920423@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later
#
# generate syslinux menuentry
# usage: UUID="$UUID" ISOFILE="$ISOFILE" LABEL="$LABEL" \
#          ./mkgrubcfg.sh <entryfile>
#
# variables in entryfile:
# - UUID: the UUID of the partition
# - ISOFILE: the file name of iso (needed to pass to the entry file)
# - LABEL: syslinux label
#
# parameters in entry file:
# - TITLE: GRUB menu entry title
# - KERNEL: path to kernel image
# - INITRD: path to initramfs/initrd image
# - OPTION: kernel command line
# - X64: y/n, indicates whether it's 64-bit

source "$1"
_INITRD=$(echo ${INITRD[*]}|sed 's/ /,/g')

cat << EOF
LABEL $LABEL
MENU LABEL $TITLE
LINUX $KERNEL
INITRD $_INITRD
APPEND $OPTION
EOF

echo
