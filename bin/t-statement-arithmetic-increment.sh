#! /usr/bin/env bash
#
# Q: POSIX `i=$((i + 1))` vs `((i++))` vs `let i++` etc.
# A: No noticeable difference, POSIX `i=$((i + 1))` will do fine
# priority: 10
#
#     t1  real 0m0.045s i=$((i + 1)) POSIX
#     t2a real 0m0.072s : $((i + 1)) POSIX (side effect)
#     t2b real 0m0.063s : $((i++))   POSIX (side effect)
#     t3  real 0m0.039s ((i++))      Bash
#     t4  real 0m0.053s let i++      Bash
#
# Notes:
#
# The tests were using 10 000 repeats, which is
# unrealistic for any program. There really is no
# practical difference whichever you choose. The
# portable POSIX version works in all shells:
# `i=$((i + 1))`.
#
# When run under `ksh93`, the tests seems be
# optimized for  `((...))` operator which is
# about 2x faster:
#
#     t1  real 0m0.029s i=$((i + 1)) POSIX
#     t2a real 0m0.044s : $((i + 1)) POSIX (side effect)
#     t2b real 0m0.044s : $((i++))   POSIX (side effect)
#     t3  real 0m0.014s ((i++))      Bash
#     t4  real 0m0.034s let i++      Bash

[ "${loop_max:+user}" = "user" ] && loop_count=$loop_max

. ./t-lib.sh ; f=$random_file

loop_max=${loop_count:-10000}

t1 ()
{
    item=0
    for i in $(seq $loop_max)
    do
        item=$((item + 1))  # traditional
    done
}

t2a ()
{
    item=0
    for i in $(seq $loop_max)
    do
        : $((item = item + 1))
    done
}

t2b ()
{
    item=0
    for i in $(seq $loop_max)
    do
        : $((item++))
    done
}

t3 ()
{
    item=0
    for i in $(seq $loop_max)
    do
        ((item++))
    done
}

t4 ()
{
    item=0
    for i in $(seq $loop_max)
    do
        let item++
    done
}

t="\
:t t1
:t t2a
:t t2b
:t t3
:t t4
"

[ "$source" ] || RunTests "$t" "$@"

# End of file
