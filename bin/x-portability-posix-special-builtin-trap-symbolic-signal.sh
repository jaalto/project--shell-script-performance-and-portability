#! /bin/sh
# Short: POSIX trap -SIG
# Desc: Test POSIX Special Built-in support: trap with symbolic signal name
# Url: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html#tag_18_28_01

trap 'echo' INT

# output of trap(1) call:
# trap -- 'echo' SIGINT

case $(trap) in
    *echo*INT*)
        exit 0
        ;;
    *)
        exit 1
esac
