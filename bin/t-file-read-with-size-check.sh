#! /bin/bash
#
# Q: Is empty file check useful before reading file's content?
# A: It is about 10x faster to use `[ -s file ]` before reading
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
    for i in $(seq $loop_max)
    do
        val=$(< $f)
    done
}

t2 ()
{
    for i in $(seq $loop_max)
    do
        [ -s $f ] && val=$(< $f)
    done
}

trap AtExit EXIT HUP INT QUIT TERM

echo "1" > $tmp

t t1
t t2

# End of file
