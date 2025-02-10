# -*- mode: makefile; -*-
#

.PHONY: all
all:
	cd bin && \
	../results.sh

run:
	cd bin && \
	../run.sh t-*

# End of file
