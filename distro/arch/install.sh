install_live() {
	install -d "$DATADIR/$KEYWORD" "$KERNELDIR/$KEYWORD"
	iso_extract "${ISO_FILEPATH}" arch/boot/x86_64 'arch/boot/*.img' "$KERNELDIR/$KEYWORD/"
	cp "${ISO_FILEPATH}" "$DATADIR/$KEYWORD/"
}

