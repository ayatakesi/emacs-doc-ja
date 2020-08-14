.PHONY: emacs
.PHONY: lispref
.PHONY: clean

all: emacs lispref

emacs:
	$(MAKE) -C emacs emacs

lispref:
	$(MAKE) -C lispref lispref

clean:
	$(MAKE) -C emacs clean
	$(MAKE) -C lispref clean
