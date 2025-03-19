#! /bin/bash
#
# Q: Should you test existense before copying?
# A: It is about 50x faster is you test existense before copying.
# priority: 1
#
#     t1 real 0m0.013s <file test> cp
#     t2 real 0m0.009s <file test> cp (hardlink)
#     t3 real 0m1.812s cp A B
#
# Code:
#
#     t1 [ A -nt B ] || cp --preserve=timestamps ...
#     t2 [ A -ef B ] || cp --preserve=timestamps --link ...
#     t3 cp --preserve=timestamps A B

. ./t-lib.sh ; f=$random_file

copy="$f.copy.tmp"
rm --force "$copy"

AtExit ()
{
    [ "$copy" ] || return 0
    rm --force "$copy"
}

t1 ()
{
    # when called: $copy already exist (as it should)

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
        if [ ! -e $copy ]; then
            if [ ! $f -ef $copy ]; then  # not the same hardlink?
                cp --preserve=timestamps --link $f $copy # make a hardlink
            fi
        fi
    done
}

t3 ()
{
    for i in $(seq $loop_max)
    do
        cp --preserve=timestamps $f $copy
    done
}


trap AtExit EXIT HUP INT QUIT TERM

rm --force "$copy"
t t1

rm --force "$copy"
t t2

rm --force "$copy"
t t3


# End of file
