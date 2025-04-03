#! /bin/sh
# Short: POSIX shift N and $?
# Desc: Test POSIX Special Built-in support: shift N, when not enough args
# Url: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html#tag_18_26_01
#
# Notes:
#
# POSIX: "(...) If the n operand is invalid
# or is greater than `$#`, this may be
# considered a syntax error and a non-interactive
# shell may exit"
#
# Issues with `shift N` if there was not
# enough args to shift.
#
# Behaviour is not uniform accross shells.
# Run this file under debug to see behavior.
#
#     $sh -x <file>
#
#     posh       : error and exit with code 1
#     dash       : error and exit with code 2
#     mksh       : error and exit with code 1
#     ksh93      : error and exit with code 1
#     busybox ash: no error message and $? is set to 1
#     bash       : no error message and $? is set to 1
#     zsh        : error message and $? is set to 1

test ()
(
    # Run test in subshell compound-list
    # to prevent premature exit call
    set -- 1
    shift 2
    echo "x$?"
)

file=t.ret

# ignore file redirection
# shellcheck disable=SC2065

if test > "$file"; then
    # Normal program execution
    code=$(cat "$file")
    code=${code#x}
    rm -f "$file"
    [ ! "$code" = 0 ]
else
    code=$?
    rm -f "$file"
    echo "FATAL: shift called exit $code"
    exit "$code"
fi
