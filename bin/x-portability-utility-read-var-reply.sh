#! /bin/bash
# Short: read (REPLY)
# Desc: Test POSIX utlitity support: read with non-standard variable REPLY
# Url: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/read.html
#
# Notes:
#
# The POSIX `read` command requires VARIABLE.
# It does not default to variable REPLY..
# For portability supply always REPLY.
#
#     echo 1 | { read -r REPLY ; ... }

echo 1 | read -r
