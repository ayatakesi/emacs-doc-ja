.PHONY: clean
.PHONY: emacs

all: lispref

clean:
	rm -f japanese_texis/*;
	rm -f TITLES/ja/LC_MESSAGES/*.mo;

lispref:
	for TEXI in original_texis/*.texi; \
	do \
		../UTILS/functions.sh \
		translate_texi_except_titles \
		$${TEXI} \
		japanese_texis \
		. \
		""; \
		../UTILS/functions.sh \
		translate_title_by_gettext \
			$${TEXI} \
			japanese_texis \
			TITLES \
			"-ja"; \
		rm -f japanese_texis/$$(basename $${TEXI}); \
	done

