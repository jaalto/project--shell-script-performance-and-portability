#! /usr/bin/env bash
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

f=$TMPBASE.random.dictionary.$size

Setup ()
{
    RandomWordsDictionary $size > $f
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

# Hide test case from other shells
t2 () { : ; } # stub

cat << 'EOF' > t.bash
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
EOF

IsFeatureProcessSubstitution && . ./t.bash
rm --force t.bash

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

t="\
:t t1
:t t2 IsFeatureProcessSubstitution
:t t3
"

Setup
SetupAtExit

[ "$source" ] || RunTests "$t" "$@"

# End of file
