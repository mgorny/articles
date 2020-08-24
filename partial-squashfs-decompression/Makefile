PDF = partial-squashfs-decompression.pdf
EXTRA = \
	$(patsubst %.pdf,%.aux,$(PDF)) \
	$(patsubst %.pdf,%.log,$(PDF)) \
	$(patsubst %.pdf,%.out,$(PDF))

view: $(PDF)
	xdg-open $<
all: $(PDF)

clean:
	rm -f $(PDF) $(EXTRA)

.PHONY: view all

%.pdf: %.ltx
	xelatex $< || rm $@
	xelatex $< || rm $@
