#! /bin/bash
#
# Q: Is there pipe slower than process substitution?
# A: No different. Pipes are efficient.
#
# real    0m1.477s  pipes
# real    0m1.472s  process substitution

. ./t-lib.sh ; f=$rand

tmp=t.tmp

t1 ()
{
    for i in {1..200}
    do
        # Think "cat" as any program that produces output
        # that needs yto be processes via pipes. We just
        # do something using 2 pipes.

        cat $rand | cut -f1 | awk '/./ {}'
    done
}

t2 ()
{
    for i in {1..200}
    do
        < <( < <(cat $rand) cut -f1) awk '/./ {}'
    done
}

t ()
{
    echo -n "# $1"
    time $1
    echo
}

t t1
t t2

# End of file
