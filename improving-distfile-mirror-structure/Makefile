OUT = distfile-count-over-time.svg file-hash-1x.svg file-hash-2x.svg filename-hash-1x.svg filename-hash-2x.svg filename-hash-over-time.svg filename-prefix-layout.svg

all: $(OUT)

%.svg: %.gnuplot %.txt
	gnuplot $< > $@

clean:
	rm -f $(OUT)

.PHONY: all clean
