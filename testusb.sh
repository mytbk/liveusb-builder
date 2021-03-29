#!/bin/sh
# Copyright (C)  2021 Iru Cai <mytbk920423@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

# Test the live USB in QEMU, you need to run this script as root
if [ "$1" == uefi ]; then
	bios=(-bios /usr/share/edk2-ovmf/x64/OVMF.fd)
	shift
else
	bios=()
fi

qemu-system-x86_64 -enable-kvm -cpu host -m 2G "${bios[@]}" -drive "file=$1,format=raw"
