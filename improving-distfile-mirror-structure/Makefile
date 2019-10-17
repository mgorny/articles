OUT = distfile-count-over-time.svg distfile-size-changes.svg \
	file-hash-1x.svg file-hash-2x.svg filename-hash-1x.svg \
	filename-hash-2x.svg filename-hash-over-time.svg \
	filename-prefix-layout.svg

all: $(OUT)

distfile-count-over-time.txt:
	+cd distfile-count-over-time-data && $(MAKE) data.txt
	echo "Date Digest-count Manifest2-count Total-count Digest-size Manifest2-size Total-size" > $@
	cat distfile-count-over-time-data/data.txt >> $@

distfile-size-changes.txt:
	+cd distfile-count-over-time-data && $(MAKE) diffsize.txt
	echo "Date Removals Additions" > $@
	cat distfile-count-over-time-data/diffsize.txt >> $@

%.svg: %.gnuplot %.txt
	gnuplot $< > $@

clean:
	rm -f $(OUT)

distclean: clean
	rm -f distfile-count-over-time.txt
	+cd distfile-count-over-time-data && $(MAKE) clean

.PHONY: all clean distclean
