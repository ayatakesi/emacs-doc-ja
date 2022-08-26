.PHONY: emacs
.PHONY: lispref
.PHONY: lispintr
.PHONY: clean
.PHONY: update

all: emacs lispref lispintr

update:
	$(MAKE) -C emacs update
	$(MAKE) -C lispref update
	$(MAKE) -C lispintr update

emacs:
	$(MAKE) -C emacs emacs

lispref:
	$(MAKE) -C lispref lispref

lispintr:
	$(MAKE) -C lispintr lispintr

clean:
	$(MAKE) -C emacs clean
	$(MAKE) -C lispref clean
	$(MAKE) -C lispintr clean
