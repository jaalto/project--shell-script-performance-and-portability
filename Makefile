# -*- mode: makefile-gmake; -*-

ifneq (,)
    This makefile requires GNU Make.
endif

DOCDIR   = doc
MAKEFILE = Makefile
DOC      = RESULTS.txt
BRIEF    = RESULTS-BRIEF.txt
BIN_RUN  = run.sh
BIN_DOC  = results.sh
GREP     = grep --extended-regexp
RM	 = rm --force

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
	@cd bin && \
	./$(BIN_DOC) t-*

# run - Run tests
.PHONY: run
run:
	cd bin && \
	./$(BIN_RUN) t-*

# doc - Generate documentation
.PHONY: doc
doc: doc-all doc-brief

define doc-function
	cd bin && \
	./$(BIN_DOC) t-* > ../$(DOCDIR)/$(DOC)
endef

.PHONY: doc-all
doc-all:
	$(call doc-function)

$(DOCDIR)/$(DOC):
	$(call doc-function)

.PHONY: doc-brief
doc-brief: $(DOCDIR)/$(DOC)
	$(GREP) "^($$|FILE:|# [QA]:)" $(DOCDIR)/$(DOC) > $(DOCDIR)/$(BRIEF)

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
