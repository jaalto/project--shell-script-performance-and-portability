#! /bin/bash
# Short: POSIX read (-N)
# Desc: Test POSIX utlitity support: read with non-standard option -N<size>
# Url: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/read.html
#
# Notes:
#
# The `read` command is defined in POSIX, but
# the `-N` option is not. Test if `-N` is supported
# and whether a file can be read into memory
# using the variable `$REPLY`.

f="t.tmp"
: > "$f"

read -r -N10 REPLY < "$f"
code=$?

rm -f "$f"
exit $code
