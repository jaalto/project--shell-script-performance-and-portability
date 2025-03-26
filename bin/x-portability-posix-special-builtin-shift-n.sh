#! /bin/sh
# Short: POSIX shift N and $?
# Desc: Test POSIX Special Built-in support: shift N, when not enough args
# Url: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_26_01
#
# Notes:
#
# POSIX: "(...) If the n operand is invalid
# or is greater than "$#", this may be
# considered a syntax"
#
# Somewhere there was mentioned that there
# were compatibility issues with `shift N`
# if there was not enough args to shift.
#
# Probably the status code
# is not uniform accross shells.
#
# TODO: find reference

set - 1
shift 2

# Should indicate correct error code
[ ! $? = 0 ]
