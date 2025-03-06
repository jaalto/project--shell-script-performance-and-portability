#! /bin/bash
#
# Q: `cmd | while` vs `while ... done < <(process substitution)`
# A: No real difference. Process substitution preserves variables in loop.
# priority: 0
#
# t1 real    0m0.750s  cmd | while
# t2 real    0m0.760s  process substitution
#
# Code:
#
# cmd | while read -r ... done      # t1
# while read -r ... done < <(cmd)   # t2
#
# Notes:
#
# There is no practical difference.
#
# Process substitution is more general because the
# `while` loop runs under the same environment, and
# any variables defined or set will persist
# afterward.

. ./t-lib.sh # ; f=$random_file

size=${size:-10k}

dict=t.random.dictionary.$size
f=$dict

AtExit ()
{
    [ "$dict" ] || return 0
    [ -f "$dict" ] || return 0

    rm --force "$dict"
}

Setup ()
{
    RandomWordsDictionary $size > $dict
}

t1 ()
{
    for i in $(seq $loop_max)
    do
        cut --delimiter=" " --fields=1 $f |
        while read -r item
        do
            item=$item
        done
    done
}

t2 ()
{
    for i in $(seq $loop_max)
    do
        while read -r item
        do
            item=$item
        done < <(cut --delimiter=" " --fields=1 $f)
    done
}

Setup
t t1
t t2

# End of file
