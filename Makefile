# -*- mode: makefile; -*-
#

DOC     = RESULTS.txt
BRIEF   = RESULTS-BRIEF.txt
BIN_RUN = run.sh
BIN_DOC = results.sh

.PHONY: all
all:
	cd bin && \
	../$(BIN_DOC) t-*

.PHONY: run
run:
	cd bin && \
	../$(BIN_RUN) t-*

.PHONY: doc
doc: doc-all doc-brief

.PHONY: doc-all
doc-all:
	cd bin && \
	../$(BIN_DOC) t-* > ../$(DOC)

.PHONY: doc-bried
doc-brief:
	grep --extended-regexp "^($$|FILE:|# [QA]:)" $(DOC) > $(BRIEF)

# End of file
