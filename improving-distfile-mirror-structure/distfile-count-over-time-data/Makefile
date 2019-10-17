# this must be full git clone with historical repo grafted
GENTOO_GIT = ~/git/gentoo
PYTHON = python

FILES = monthly-commit-ids.txt digests manifests combined data.txt diffsize.txt

all: $(FILES)

monthly-commit-ids.txt: monthly-commit-ids.py
	( cd $(GENTOO_GIT) && git log --reverse --format='%ct %H' master ) \
		| $(PYTHON) $< > $@

digests: monthly-commit-ids.txt
	mkdir -p digests.tmp
	while read d c; do \
		echo "$$d $$c" >&2; \
		( cd $(GENTOO_GIT) && git grep -h ^MD5 "$$c" '*/*/files/digest*' ) \
			| grep -v / | sort -k3 -u \
			> digests.tmp/$$d; \
	done < $<
	mv digests.tmp digests

manifests: monthly-commit-ids.txt
	mkdir -p manifests.tmp
	while read d c; do \
		echo "$$d $$c" >&2; \
		( cd $(GENTOO_GIT) && git grep -h ^DIST "$$c" '*/*/Manifest' ) \
			| sort -k2 -u \
			> manifests.tmp/$$d; \
	done < $<
	mv manifests.tmp manifests

combined: digests manifests
	mkdir -p combined.tmp
	cd digests && \
		for x in *; do \
			( \
				awk '{ print $$3 " " $$4 }' $$x && \
				awk '{ print $$2 " " $$3 }' ../manifests/$$x \
			) | sort -k1 -u > ../combined.tmp/$$x; \
		done
	mv combined.tmp combined

data.txt: digests manifests combined
	( cd combined && \
	for x in *; do \
		printf '%s %d %d %d %d %d %d\n' $$x "$$(wc -l < ../digests/$$x)" \
			"$$(wc -l < ../manifests/$$x)" "$$(wc -l < $$x)" \
			"$$(awk '{ sum += $$4 } END { print sum }' ../digests/$$x)" \
			"$$(awk '{ sum += $$3 } END { print sum }' ../manifests/$$x)" \
			"$$(awk '{ sum += $$2 } END { print sum }' $$x)"; \
	done ) > $@

diffsize.txt: combined
	( cd combined && \
	prev=; \
	for x in *; do \
		[ -n "$$prev" ] && \
			printf '%s %d %d\n' "$$x" \
				"$$(comm -23 "$$prev" "$$x" | awk '{ sum += $$2 } END { print sum }')" \
				"$$(comm -13 "$$prev" "$$x" | awk '{ sum += $$2 } END { print sum }')"; \
		prev=$$x; \
	done ) > $@

clean:
	rm -r -f $(FILES)

.PHONY: all clean
