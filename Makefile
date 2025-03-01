# -*- Makefile -*-

# --------------------------------------------------------------------
DUNE      ?= dune
ECARGS    ?=
ECTOUT    ?= 10
ECJOBS    ?= 0
ECEXTRA   ?= --report=report.log
ECPROVERS ?= Alt-Ergo@2.4 Z3@4.12 CVC5@1.0
CHECKPY   ?=
CHECK     := $(CHECKPY) scripts/testing/runtest
CHECK     += --bin=./ec.native --bin-args="$(ECARGS)"
CHECK     += --bin-args="$(ECPROVERS:%=-p %)"
CHECK     += --timeout="$(ECTOUT)" --jobs="$(ECJOBS)"
CHECK     += $(ECEXTRA) config/tests.config

# --------------------------------------------------------------------
UNAME_P = $(shell uname -p)
UNAME_S = $(shell uname -s)

# --------------------------------------------------------------------
.PHONY: default build byte native tests check examples
.PHONY: clean install uninstall

default: build
	@true

build:
	rm -f src/ec.exe ec.native
	dune build
	ln -sf src/ec.exe ec.native
ifeq ($(UNAME_P)-$(UNAME_S),arm-Darwin)
	-codesign -f -s - src/ec.exe
endif

install: build
	$(DUNE) install

uninstall:
	$(DUNE) uninstall

unit: build
	$(CHECK) unit

stdlib: build
	$(CHECK) prelude stdlib

examples: build
	$(CHECK) examples mee-cbc

check: unit stdlib examples
	@true

clean:
	rm -f ec.native && $(DUNE) clean
	find theories examples -name '*.eco' -exec rm '{}' ';'

clean_eco:
	find theories examples -name '*.eco' -exec rm '{}' ';'
