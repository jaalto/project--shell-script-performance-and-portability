#! /bin/bash
#
# Q: Is "test -s" for size useful before reading the file content?
# A: yes, much faster to check [ -s file ] before reading.
#
# real    0m0.105s $(< file)
# real    0m0.006s [ -s file] && $(< file)

. ./t-lib.sh ; f=$random_file

# local test
f=t.$$.tmp
: > $f

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
        val=$(< $f)
    done
}

t2 ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        [ -s $f ] && val=$(< $f)
    done
}

trap AtExit EXIT HUP INT QUIT TERM

echo "1" > $tmp

t t1
t t2

# End of file
