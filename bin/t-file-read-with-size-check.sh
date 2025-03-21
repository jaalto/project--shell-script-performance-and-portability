#! /usr/bin/env bash
#
# Q: Is empty file check useful before reading file's content?
# A: No need to check. Reading even empty file is fast.
# priority: 0
#
#     t1 real 0m0.166s $(< file)
#     t2 real 0m0.168s [ -s file] && $(< file)

. ./t-lib.sh ; f=$random_file

t1 ()
{
    for i in $(seq $loop_max)
    do
        val=$(< $f)
    done
}

t2 ()
{
    for i in $(seq $loop_max)
    do
        [ -s $f ] && val=$(< $f)
    done
}

t="\
:
:t t2
"

RunTests "$t" "$@"

# End of file
