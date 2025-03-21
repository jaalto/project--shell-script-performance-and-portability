#! /bin/bash
#
# Q: Should you test existense before copying?
# A: It is about 40x faster is you test existense before copying.
# priority: 1
#
#     t1 real 0m0.007s <file test> cp
#     t2 real 0m1.270s cp A B
#
# Code:
#
#     t1 [ A -nt B ] || cp --preserve=timestamps ...
#     t2 cp --preserve=timestamps A B

. ./t-lib.sh ; f=$random_file

f=$TMPBASE.file
copy=$f.copy
: > $f

t1 ()
{
    # When called: $copy must already exist

    for i in $(seq $loop_max)
    do
        if [ $f -nt $copy ]; then # if newer file, then copy
            cp --preserve=timestamps $f $copy
        fi
    done
}

t2 ()
{
    for i in $(seq $loop_max)
    do
        cp --preserve=timestamps $f $copy
    done
}

EnableDefaultTrap

t="\
:t t1
:t t2
"

RunTests "$t" "$@"

# End of file
