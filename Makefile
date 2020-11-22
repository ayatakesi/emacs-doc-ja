.PHONY: emacs
.PHONY: lispref
.PHONY: clean
.PHONY: update

all: emacs lispref

update:
	$(MAKE) -C emacs update
	$(MAKE) -C lispref update

emacs:
	$(MAKE) -C emacs emacs

lispref:
	$(MAKE) -C lispref lispref

clean:
	$(MAKE) -C emacs clean
	$(MAKE) -C lispref clean
