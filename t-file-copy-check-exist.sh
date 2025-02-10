#! /bin/bash
#
# Q: Need a COPY of file. Call cp(1), hardlink, or test -nt before copy?
# A: test -nt before cp(1) is fastestm hardlink is fast too.
#
# real    0m0.103s $(< file)
# real    0m0.002s [ -s file] && $(< file)

. ./t-lib.sh ; f=$random_file

copy="$f.copy.tmp"
rm --force "$copy"

set -x

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
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        if [ ! $f -ef $copy ]; then  # same hardlink?
            cp --preserve=timestamps --link $f $copy # make a hardlink
        fi
    done
}

t3 ()
{
    # when called: $copy already exist (as it should)

    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        if [ $copy -nt $f ]; then
            cp --preserve=timestamps $f $copy
        fi
    done
}

trap AtExit EXIT HUP INT QUIT TERM

t t1
t t2
t t3

# End of file
