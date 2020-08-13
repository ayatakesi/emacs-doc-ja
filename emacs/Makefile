.PHONY: all
.PHONY: clean

clean:
	rm -f japanese_texis/*;
	rm -f TITLES/ja/LC_MESSAGES/*.mo;

all:
	../UTILS/functions.sh \
	translate_texi_except_titles \
		original_texis \
		japanese_texis \
		. \
		"";

	for TEXI in original_texis/*.texi; \
	do \
		../UTILS/functions.sh \
		translate_title_by_gettext \
			$${TEXI} \
			japanese_texis \
			TITLES \
			"-ja"; \
	done
