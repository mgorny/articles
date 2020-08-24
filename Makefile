RST = \
	a-short-history-of-gentoo-copyright.rst \
	attack-on-git-signature-verification.rst \
	copyright-primer.rst \
	evolution-uid-trust-extrapolation.rst \
	guru-a-new-model-of-contributing-to-gentoo.rst \
	improving-distfile-mirror-structure.rst \
	new-gentoo-copyright-policy-explained.rst \
	portability-of-tar-features.rst \
	the-impact-of-cxx-templates-on-library-abi.rst \
	the-story-of-gentoo-management.rst \
	the-ultimate-guide-to-eapi-7.rst
RST2HTML = $(patsubst %.rst,%.html,$(RST))
HTML = $(RST2HTML)
PDF = \
	reducing-squashfs-delta-size-through-partial-decompression.pdf \
	using-deltas-to-speed-up-squashfs-ebuild-repository-updates.pdf

DATA_EVO = \
	evolution-uid-trust-extrapolation/forged-mail.png \
	evolution-uid-trust-extrapolation/trusted-sig.png \
	evolution-uid-trust-extrapolation/untrusted-sig.png
DATA_GF_INCOME = \
	gf-income/gf-income-partial.svg \
	gf-income/gf-income.svg
DATA_GURU = \
	guru-a-new-model-of-contributing-to-gentoo/contrib-method-chart.svg \
	guru-a-new-model-of-contributing-to-gentoo/guru.svg
DATA_DISTFILE = \
	improving-distfile-mirror-structure/distfile-count-over-time.svg \
	improving-distfile-mirror-structure/distfile-size-changes.svg \
	improving-distfile-mirror-structure/file-hash-1x.svg \
	improving-distfile-mirror-structure/file-hash-2x.svg \
	improving-distfile-mirror-structure/filename-hash-1x.svg \
	improving-distfile-mirror-structure/filename-hash-2x.svg \
	improving-distfile-mirror-structure/filename-hash-over-time.svg \
	improving-distfile-mirror-structure/filename-prefix-layout.svg

all: $(HTML) $(PDF)
	$(MAKE) -C improving-distfile-mirror-structure

install: all
	@if [ -z "$(DESTDIR)" ]; then echo "Please pass DESTDIR!"; exit 1; fi
	install -d -m0755 "$(DESTDIR)"
	install -m0644 $(RST) $(HTML) $(PDF) "$(DESTDIR)"/
	$(MAKE) install-evo-data install-gf-income install-guru \
		install-distfile

install-evo-data:
	install -d -m0755 "$(DESTDIR)"/evolution-uid-trust-extrapolation
	install -m0644 $(DATA_EVO) "$(DESTDIR)"/evolution-uid-trust-extrapolation

install-gf-income:
	install -d -m0755 "$(DESTDIR)"/gf-income
	install -m0644 $(DATA_GF_INCOME) "$(DESTDIR)"/gf-income

install-guru:
	install -d -m0755 "$(DESTDIR)"/guru-a-new-model-of-contributing-to-gentoo
	install -m0644 $(DATA_GURU) "$(DESTDIR)"/guru-a-new-model-of-contributing-to-gentoo

install-distfile: all
	install -d -m0755 "$(DESTDIR)"/improving-distfile-mirror-structure
	install -m0644 $(DATA_DISTFILE) "$(DESTDIR)"/improving-distfile-mirror-structure

clean:
	rm -f $(RST2HTML) $(PDF)
	$(MAKE) -C improving-distfile-mirror-structure clean
	$(MAKE) -C partial-squashfs-decompression clean
	$(MAKE) -C squashfs-deltas clean

%.html: %.rst
	rst2html5.py $< > $@

reducing-squashfs-delta-size-through-partial-decompression.pdf:
	$(MAKE) -C partial-squashfs-decompression all
	cp partial-squashfs-decompression/partial-squashfs-decompression.pdf \
		$@

using-deltas-to-speed-up-squashfs-ebuild-repository-updates.pdf:
	$(MAKE) -C squashfs-deltas all
	cp squashfs-deltas/squashfs-deltas.pdf $@
