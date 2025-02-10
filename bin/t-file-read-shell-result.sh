#! /bin/bash
#
# Q: Is capturing var=$() faster or using temporary file for outpur?
# A: The var=$() is 2x faster than using a temporary file
#
# t1 real    0m0.428s val=$(cmd)
# t2 real    0m0.899s cmd > file; val=$(< file)

. ./t-lib.sh ; f=$random_file

tmp=t.$$.tmp

AtExit ()
{
    [ -f "$tmp" ] || return 0

    rm --force "$tmp"
}

t1 ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        count=$(grep --count --fixed-strings "12" $f)
    done
}

t2 ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        grep --count --fixed-strings "12" $f > $tmp
        count=$(< $tmp)
    done
}

trap AtExit EXIT HUP INT QUIT TERM

t t1
t t2

# End of file
