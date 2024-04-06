#! /bin/bash
#
# Q: Which one is faster: just $() or saving content to file and then reading file?
# A: The $() is faster than using a temporary file
#
# real    0m0.428s val=$(shell)
# real    0m0.899s shell > file; val=$(< file)

. ./t-lib.sh ; f=$rand

tmp=t.tmp

t1 ()
{
    for i in {1..100}
    do
        count=$(grep --count --fixed-strings "12" $f)
    done
}

t2 ()
{
    for i in {1..100}
    do
        grep --count --fixed-strings "12" $f > $tmp
        local count=$(< $tmp)
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
