# -*- mode: makefile; -*-
#

.PHONY: all
all:
	cd bin && \
	../results.sh t-*

run:
	cd bin && \
	../run.sh t-*

# End of file
