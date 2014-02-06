view: squashfs-deltas.pdf
	xdg-open $<
all: squashfs-deltas.pdf

.PHONY: view all
.SUFFIXES: .ltx .pdf

.ltx.pdf:
	xelatex $<

squashfs-deltas.pdf: $(glob data/*)
