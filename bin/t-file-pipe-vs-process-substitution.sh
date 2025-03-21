#! /usr/bin/env bash
#
# Q: Would pipe be slower than using process substitution?
# A: No notable difference. Pipes are efficient.
# priority: 0
#
#     t1 real 0m0.790s  pipes
#     t2 real 0m0.745s  process substitution
#
# Code:
#
#     cmd | cmd | cmd           # t1
#     < <( < <(cmd) cmd) cmd    # t2

. ./t-lib.sh ; f=$random_file

t1 ()
{
    for i in $(seq $loop_max)
    do
        # Think "cat" as any program that produces output
        # that needs to be send to pipes. We just
        # cook up something using 2 pipes.
        cat $f | cut -f1 | $AWK '/./ {}'
    done
}

t2 ()
{
    for i in $(seq $loop_max)
    do
        < <( < <(cat $f) cut -f1) $AWK '/./ {}'
    done
}

t="\
:t t1
:t t2
"

RunTests "$t" "$@"

# End of file
