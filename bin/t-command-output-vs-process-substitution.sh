#! /bin/bash
#
# Q: `cmd | while` vs `while ... done < <(process substitution)`
# A: No notable difference. Process substitution preserves variables in loop.
# priority: 1
#
#     t1 real 0m0.670s  POSIX. cmd > file ; while ... < file
#     t2 real 0m0.760s  Bash process substitution
#     t3 real 0m0.780s  POSIX. cmd | while
#
# Code:
#
#     t1 cmd > file ;  while read -r ... done < file
#     t2 while read -r ... done < <(cmd)
#     t3 cmd | while read -r ... done
#
# Notes:
#
# There is no practical difference.
#
# Process substitution is general because the
# `while` loop runs under the same environment, and
# any variables defined or set will persist
# afer the loop.
#
# Even though t1 (POSIX), which uses a temporary
# file, seems to be faster, it really isn't. What is
# not shown in the measurement is the extra `rm`
# cleanup for the temporary file, which must be taken
# into account, thus nullifying any perceived speed
# gains.

. ./t-lib.sh # ; f=$random_file

RequireDictionary "t-command-output-vs-process-substitution.sh"

size=${size:-10k}

dict=t.random.dictionary.$size
f=$dict

TMPBASE=${TMPDIR:-/tmp}/${LOGNAME:-$USER}.$$.test.compgen.tmp

AtExit ()
{
    [ "$dict" ] || return 0
    [ -f "$dict" ] || return 0

    rm --force "$dict" "$TMPBASE"*
}

Setup ()
{
    RandomWordsDictionary $size > $dict
}

t1 () # POSIX
{
    tmp=$TMPBASE.cut

    for i in $(seq $loop_max)
    do
        cut --delimiter=" " --fields=1 $f > $tmp
        while read -r item
        do
            item=$item
        done < $tmp
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

t3 () # POSIX
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

trap AtExit EXIT HUP INT QUIT TERM

Setup
t t1
t t2 IsShellBash
t t3

# End of file
