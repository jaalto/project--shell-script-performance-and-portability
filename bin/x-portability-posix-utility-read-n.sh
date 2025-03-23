#! /bin/sh
# Q: POSIX support: read -N<size>
#
# The `read` is defined in POSIX, but
# option `-N` is not. Test if -N is supported.

f=t.tmp
: > $f

read -N10 < "$f"

rm --force $f
