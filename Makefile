# -*- mode: makefile-gmake; -*-

ifneq (,)
    This makefile requires GNU Make.
endif

DOCDIR   = doc
MAKEFILE = Makefile
DOC      = RESULTS
BRIEF    = RESULTS-BRIEF.txt
DOC_PORTABILITY = RESULTS-PORTABILITY.txt
BINDIR	 = bin

GREP     = grep --extended-regexp
RM	 = rm --force
BIN_RUN  = run.sh
BIN_DOC  = results.sh
BIN_PORTABILITY = portability.sh

.DEFAULT_GOAL := all

# all - alias to 'help'
.PHONY: all
all: help

# help - Display make targets
.PHONY: help
help:
	@echo "# Synopsis: make <target>"
	@$(GREP) '^# [^#-]+- ' $(MAKEFILE) | \
	    awk '\
	    { \
		sub("^# ", ""); \
		target = $$1; \
		sub(target " +- +", ""); \
		printf("%-12s %s\n", target, $$0); \
	    }'

# show - Show test results (!)
.PHONY: show
show:
	@cd $(BINDIR) && \
	./$(BIN_DOC) t-*

# run - Run performance tests
.PHONY: run
run:
	cd $(BINDIR) && \
	./$(BIN_RUN) t-*

# run-tests - Run all test cases
.PHONY: run-tests
run-tests:
	cd $(BINDIR) && \
	./run-all.sh

# portability - Run portability tests
.PHONY: portability
portability:
	cd $(BINDIR) && \
	./$(BIN_PORTABILITY) x-*

# doc - Generate documentation
.PHONY: doc
doc: doc-all doc-brief doc-portability

define doc-function
	cd $(BINDIR) && \
	./$(BIN_DOC) $$(ls t-* | grep -v t-lib.sh) > ../$(DOCDIR)/$(DOC).txt
	bin/txt2markdown.sh $(DOCDIR)/$(DOC).txt > $(DOCDIR)/$(DOC).md
endef

.PHONY: doc-all
doc-all:
	$(call doc-function)

define doc-portability-function
	cd $(BINDIR) && \
	./$(BIN_PORTABILITY) x-* > ../$(DOCDIR)/$(DOC_PORTABILITY)
endef

# port - Display portability results
.PHONY: port
port: cat-portability

.PHONY: cat-portability
cat-portability:
	@cat $(DOCDIR)/$(DOC_PORTABILITY)

.PHONY: doc-portability
doc-portability:
	$(call doc-portability-function)

$(DOCDIR)/$(DOC):
	$(call doc-function)

.PHONY: doc-brief
doc-brief: $(DOCDIR)/$(DOC).txt
	$(GREP) "^($$|FILE:|# [QA]:)" $(DOCDIR)/$(DOC).txt > $(DOCDIR)/$(BRIEF)

# ls - list *.sh files in bin/
ls:
	@cd $(BINDIR) && \
	ls -1 *.sh | grep --extended-regexp --invert-match 't-lib.sh|^..?-'

# clean - Delete generated doc files
.PHONY: clean
clean:
	$(RM) $(DOCDIR)/*

# distclean - Delete all generated files
.PHONY: distclean
distclean: clean
	$(RM) bin/t.*

# realclean - Delete totally all generated files
.PHONY: realclean
realclean: distclean

# End of file
