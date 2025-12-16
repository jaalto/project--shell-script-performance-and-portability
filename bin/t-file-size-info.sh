#! /usr/bin/env bash
#
# Q: What is the fastest way to read a file's size?
# A: Use `stat` or portable GNU `wc -c`.
# priority: 5
#
#     t1 real 0m0.288s stat -c file
#     t2 real 0m0.380s wc -c file; GNU version efectively is like stat
#     t3 real 0m0.461s ls -l + awk
#
# Notes:
#
# If you don't need portability, `stat` is the
# fastest. The caveat is that it is not defined in
# POSIX, and the options differ from one operating
# system to another.

. ./t-lib.sh ; f=$random_file

t1 ()
{
    for i in $(seq $loop_max)
    do
        size=$($STAT -c %s "$f")
    done
}

t2 ()
{
    for i in $(seq $loop_max)
    do
        # More portable
        #
        # GNU  coreutils implementation optimizes this
        # away using fstat(). Efectively same as stat().
        size=$(wc -c "$f")
    done
}

t3 ()
{
    for i in $(seq $loop_max)
    do
        size=$(ls -l "$f" | $AWK '{print $5; exit}')
    done
}

t="\
:t t1
:t t2
:t t3
"

if [ "$source" ]; then
     :
elif [ "$run" ]; then
    "$@"
else
    RunTests "$t" "$@"
fi

# End of file
