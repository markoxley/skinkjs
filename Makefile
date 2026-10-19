# Makefile for skinkjs (Skink to ECMAScript/JavaScript Transpiler)
#
# Usage:
#   make          - build the skinkjs binary
#   make check    - type-check skinkjs without linking
#   make test     - run skinkjs unit and integration test suite
#   make install  - install skinkjs to $(BINDIR)
#   make clean    - remove build artifacts

SKINK_PREFIX ?= $(HOME)/.local/skink
BINDIR       ?= $(SKINK_PREFIX)/bin
SKINK        ?= $(abspath ../../skink/skink)
SKINK_HOME   ?= $(abspath ../../skink/std)

SKINKJS_BIN  := skinkjs
SKINKJS_MAIN := skinkjs.skink
SKINKJS_PKGS := $(wildcard pkg/*.skink) version.skink

.DEFAULT_GOAL := all
.PHONY: all build check test install uninstall clean help

all: build

build: $(SKINKJS_BIN)

$(SKINKJS_BIN): $(SKINKJS_MAIN) $(SKINKJS_PKGS)
	@echo "Building skinkjs..."
	SKINK_HOME=$(SKINK_HOME) $(SKINK) -o $(SKINKJS_BIN) $(SKINKJS_MAIN)
	@echo "Built: $(SKINKJS_BIN)"

check:
	@echo "Type-checking skinkjs..."
	SKINK_HOME=$(SKINK_HOME) $(SKINK) -check $(SKINKJS_MAIN)

test: build
	@echo "Running skinkjs test suite..."
	SKINK_HOME=$(SKINK_HOME) $(SKINK) -t skinkjs_test.skink

install: build
	@echo "Installing skinkjs to $(BINDIR)..."
	install -d $(BINDIR)
	cp -f $(SKINKJS_BIN) $(BINDIR)/$(SKINKJS_BIN)
	chmod 755 $(BINDIR)/$(SKINKJS_BIN)
	@echo "Installed: $(BINDIR)/$(SKINKJS_BIN)"

uninstall:
	rm -f $(BINDIR)/$(SKINKJS_BIN)

clean:
	rm -f $(SKINKJS_BIN) *.ll *.o __skink_test_bin*

help:
	@echo "skinkjs Build System"
	@echo "  make          - Build skinkjs binary"
	@echo "  make check    - Type-check only"
	@echo "  make test     - Run unit & integration tests"
	@echo "  make install  - Install skinkjs to $(BINDIR)"
	@echo "  make clean    - Remove build artifacts"
