.PHONY: clean
.PHONY: emacs

all: emacs

clean:
	rm -f japanese_texis/*.texi;
	rm -f TITLES/ja/LC_MESSAGES/*.mo;

emacs:
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
		../UTILS/functions.sh \
		rm -f japanese_texis/$$(basename $${TEXI}); \
	done
	../UTILS/functions.sh \
	sed_for_L11N_name_at_include \
		original_texis \
		japanese_texis \
		"-ja";


