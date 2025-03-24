#! /bin/sh
# Q: Test POSIX support: read with non-standard option -N<size>
#
# Notes:
#
# The `read` command is defined in POSIX, but
# the `-N` option is not. Test if `-N` is supported
# and whether a file can be read into memory
# using the variable `$REPLY`.

f=t.tmp
: > $f

read -N10 < "$f"

rm --force $f
