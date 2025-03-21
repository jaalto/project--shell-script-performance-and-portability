#! /usr/bin/env bash
#
# Q: To return value from function: nameref vs `val=$(funcall)`
# A: It is about 8x faster to use nameref to return value from a function
# priority: 10
#
#     t1 real 0m0.006s t2 funcall POSIX nameref
#     t2 real 0m0.055s t1 $(funcall)
#     t3 real 0m0.005s t2 funcall Bash nameref
#
# Code:
#
#     t1 fn(): ret=$1; ... eval "$ret=\$value"
#     t2 fn(): ... echo "<value>"
#     t3 fn(): local -n ret=$1; ... ret=$value
#
# Notes:
#
# In Bash, calling functions using
# `$()` is expensive.
#
# In Ksh, `$()` does not slow down the
# code, and the times for t1 and t2 are
# the same.
#
# It is possible to use `eval` to emulate
# Bash's nameref `local -n var=...` syntax.
# However, the POSIX approach is problematic
# with nested function call chains, where each
# nameref must have a unique variable name.
#
#   fn11: nameref1
#     fn2: nameref2
#       ...

. ./t-lib.sh ; f=$random_file

Funcall ()
{
    result="return value"
    echo "$result"
}

NamerefPosix () # POSIX
{
    retval=$1  # nameref attribute, a reference to variable

    result="return value"

    eval "$retval=\$result"
}

NamerefBash () # Bash
{
    local -n retval=$1  # nameref attribute, a reference to variable

    result="return value"
    retval="$result"
}

t1 ()
{
    val=""

    for i in $(seq $loop_max)
    do
        NamerefPosix val
    done
}

t2 ()
{
    val=""

    for i in $(seq $loop_max)
    do
        val=$(Funcall)
    done
}

t3 ()
{
    val=""

    for i in $(seq $loop_max)
    do
        NamerefBash val
    done
}

Run ()
{
    if [ "$1" ]; then
        "$@"
    else
        t t1
        t t2
        t t3 IsShellBash
    fi
}

t="\
:t t1
:t t2
:t t3 IsShellBash
"

RunTests "$t" "$@"

# End of file
