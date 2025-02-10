#! /bin/bash
#
# Q: Would pipe be slower than using process substitution?
# A: No real difference. Pipes are efficient.
#
# t1 real    0m0.790s  pipes
# t2 real    0m0.745s  process substitution
#
# Code:
#
# cmd | cmd | cmd           # t1
# < <( < <(cmd) cmd) cmd    # t2

. ./t-lib.sh ; f=$random_file

t1 ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))

        # Think "cat" as any program that produces output
        # that needs to be send to pipes. We just
        # cook up something using 2 pipes.

        cat $f | cut -f1 | awk '/./ {}'
    done
}

t2 ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        < <( < <(cat $f) cut -f1) awk '/./ {}'
    done
}

t t1
t t2

# End of file
