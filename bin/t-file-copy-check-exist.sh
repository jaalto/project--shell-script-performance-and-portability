#! /bin/bash
#
# Q: If you need a copy of file, should you test before copy?
# A: Yes, test existense of file before cp(1). Hardlinks are fast.
#
#     t1 real    0m1.002s cp A B
#     t2 real    0m0.013s <file test> cp
#     t2 real    0m0.009s <file test> cp (hardlink)
#
# Code:
#
#     t1 cp --preserve=timestamps A B
#     t2 [ A -nt B ] || cp --preserve=timestamps ...
#     t3 [ A -ef B ] || cp --preserve=timestamps --link ...

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
    for i in $(seq $loop_max)
    do
        cp --preserve=timestamps $f $copy
    done
}

t2 ()
{
    # when called: $copy already exist (as it should)

    for i in $(seq $loop_max)
    do
        if [ $f -nt $copy ]; then # if newer file, then copy
            cp --preserve=timestamps $f $copy
        fi
    done
}

t3 ()
{
    for i in $(seq $loop_max)
    do
        if [ ! $f -ef $copy ]; then  # not the same hardlink?
            cp --preserve=timestamps --link $f $copy # make a hardlink
        fi
    done
}

trap AtExit EXIT HUP INT QUIT TERM

t t1

rm --force "$copy"
t t2

rm --force "$copy"
t t3

# End of file
