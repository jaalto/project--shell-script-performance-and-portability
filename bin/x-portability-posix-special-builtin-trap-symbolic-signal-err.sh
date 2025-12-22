#! /bin/sh
# Short: trap -ERR
# Desc: Test POSIX Special Built-in support: trap with non-POSIX symbolic signal ERR
# Url: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html#tag_18_28_01

trap ':' ERR 2> /dev/null
