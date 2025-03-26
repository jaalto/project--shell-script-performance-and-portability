#! /bin/sh
# Short: POSIX shift N
# Desc: Test POSIX Special Built-in support: shift N
# Url: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_26_01

set - 1 2
shift 2

[ "$*" = "" ]

