# generate GRUB menuentry
# usage: UUID="$UUID" ISOFILE="$ISOFILE" ./mkgrubcfg.sh <entryfile>
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

source "$1"

cat << EOF
menuentry '$TITLE' {
	linux $KERNEL $OPTION
	initrd ${INITRD[@]}
}
EOF

echo
