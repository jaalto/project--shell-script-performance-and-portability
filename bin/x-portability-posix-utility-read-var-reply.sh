#! /bin/bash
# Short: POSIX read (REPLY)
# Desc: Test POSIX utlitity support: read with non-standard variable REPLY
# Url: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/read.html
#
# Notes:
#
# The POSIX `read` command requires VARIABLE.
# It does not default to variable REPLY variable.
# For portability supply always REPLY.

echo 1 | read -r
