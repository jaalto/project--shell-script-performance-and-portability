#! /bin/bash
#
# Q: To return value from function: nameref vs `val=$(funcall)`
# A: It is about 8x faster to use nameref to return value from a function
# priority: 10
#
#     t1 real 0m0.055s t1 $(funcall)
#     t2 real 0m0.006s t2 funcall POSIX nameref
#     t3 real 0m0.005s t2 funcall Bash nameref
#
# Code:
#
#     t1 fn(): ... echo "<value>"
#     t2 fn(): ret=$1; ... eval "$ret=\$value"
#     t3 fn(): local -n ret=$1; ... ret=$value
#
# Notes:
#
# Calling functions using `$()` is epxensive.
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

f1 ()
{
    result="return value"
    echo "$result"
}

f2 () # POSIX
{
    retval=$1  # nameref attribute, a reference to variable

    result="return value"

    eval "$retval=\$result"
}

f3 () # Bash
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
        val=$(f1)
    done
}

t2 ()
{
    val=""

    for i in $(seq $loop_max)
    do
        f2 val
    done
}

t3 ()
{
    val=""

    for i in $(seq $loop_max)
    do
        f3 val
    done
}

t t1
t t2
t t3 IsShellBash

# End of file
