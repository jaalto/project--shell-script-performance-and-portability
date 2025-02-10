#! /bin/bash
#
# Q: Need a copy of file. Call cp(1), make hardlink, or do test before copy?
# A: Faster is to test existense of file before cp(1). Hardlink is fast.
#
# t1 real    0m1.002s cp A B
# t2 real    0m0.013s test(1) -nt ...
# t2 real    0m0.009s test(1) -ef ... (using hardlink)
#
# Code:
#
# cp --preserve=timestamps A B                       # t1
# [ A -nt B ] || cp --preserve=timestamps ...        # t2
# [ A -ef B ] || cp --preserve=timestamps --link ... # t3

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
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        cp --preserve=timestamps $f $copy
    done
}

t2 ()
{
    # when called: $copy already exist (as it should)

    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        if [ $f -nt $copy ]; then # if newer file, then copy
            cp --preserve=timestamps $f $copy
        fi
    done
}

t3 ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        if [ ! $f -ef $copy ]; then  # same hardlink?
            cp --preserve=timestamps --link $f $copy # make a hardlink
        fi
    done
}

#trap AtExit EXIT HUP INT QUIT TERM

t t1
rm --force "$copy"
t t2
rm --force "$copy"
t t3

# End of file
