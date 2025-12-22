#! /bin/sh
# Short: POSIX trap -SIG
# Desc: Test POSIX Special Built-in support: trap with symbolic signal names
# Url: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html#tag_18_28_01

AtExit ()
{
    dummy="AtExit"
    exit 0
}

trap 'AtExit' EXIT

exit 1
