#! /bin/bash
# Short: POSIX read (-N)
# Desc: Test POSIX utlitity support: read with non-standard option -N<size>
# Url: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/read.html
#
# Notes:
#
# The `read` command is defined in POSIX, but
# the `-N` option is not. Test if `-N` is supported
# and whether a file can be read into memory
# using the variable `$REPLY`.

f="t.tmp"
echo "1234567890" > "$f"

REPLY=""
read -r -N1 REPLY < "$f"

code=1

case $REPLY in
  1) code=0
     ;;
esac

rm -f "$f"
exit $code
