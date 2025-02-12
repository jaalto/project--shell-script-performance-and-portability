# -*- mode: makefile-gmake; -*-

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

# show - Show test results (!)
.PHONY: show
show:
	@cd bin && \
	./$(BIN_DOC) t-*

# help - Display make targets
.PHONY: help
help:
	@echo "# Synopsis: make <target>"
	@$(GREP) '^# [^#-]+- ' $(MAKEFILE) | \
	    sort | \
	    awk '\
	    { \
		sub("^# ", ""); \
		target = $$1; \
		sub(target " +- +", ""); \
		printf("%-8s %s\n", target, $$0); \
	    }'

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

# clean - Remove generated doc files
.PHONY: clean
clean:
	$(RM) $(DOCDIR)/*

# realclean - Remove all temporary files
.PHONY: realclean
realclean: clean
	$(RM) bin/t.*

# End of file
