#! /bin/bash
# Short: POSIX read (REPLY)
# Desc: Test POSIX utlitity support: read with non-standard variable REPLY
# Url: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/read.html
#
# Notes:
#
# The POSIX `read` command does not define
# REPLY variable. For portability supply
# it in script.

f="t.tmp"
echo 1 > "$f"

read -r < "$f"

[ "${REPLY:-}" ]
code=$?

rm -f "$f"
exit $code
